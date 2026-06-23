"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { CloudUpload, FileText, Link2, ScanSearch, Sparkles, TriangleAlert } from "lucide-react";
import { api } from "@/lib/api";
import { GlassCard } from "@/components/ui/GlassCard";
import { Loader } from "@/components/ui/Loader";
import { EmptyState } from "@/components/ui/EmptyState";
import { ErrorState } from "@/components/ui/ErrorState";
import { NeonButton } from "@/components/ui/NeonButton";
import type { MatchImportRecord, ParsedBattingRow, ParsedBowlingRow, ParsedFowRow, ParsedInnings, ParsedMatchImport, Player, Team, Venue } from "@/types/cricket";
import type { ComponentType, ReactNode } from "react";

type Props = {
  teams: Team[];
  venues: Venue[];
  players: Player[];
};

const sourceTabs = [
  { id: "screenshots", label: "Upload Screenshots", icon: CloudUpload },
  { id: "url", label: "Paste Match URL", icon: Link2 },
  { id: "pdf", label: "Upload PDF/Image", icon: FileText },
] as const;

type SourceTab = (typeof sourceTabs)[number]["id"];

function createBlankParsedImport(): ParsedMatchImport {
  return {
    match_details: {
      venue: "",
      city: "",
      match_date: "",
      match_time: "",
      toss_winner: "",
      toss_decision: "",
      player_of_match: "",
      umpires: [],
      match_number: null,
    },
    innings: [
      {
        team_name: "",
        score: 0,
        wickets: 0,
        overs: 0,
        run_rate: 0,
        extras: 0,
        extras_breakdown: {},
        batting: [],
        bowling: [],
        fall_of_wickets: [],
        yet_to_bat: [],
      },
      {
        team_name: "",
        score: 0,
        wickets: 0,
        overs: 0,
        run_rate: 0,
        extras: 0,
        extras_breakdown: {},
        batting: [],
        bowling: [],
        fall_of_wickets: [],
        yet_to_bat: [],
      },
    ],
    result: {
      winner: "",
      loser: "",
      result_type: "",
      margin_runs: 0,
      margin_wickets: 0,
    },
    parser_warnings: [],
    confidence_score: 0,
  };
}

export function AutoMatchImportForm({ teams, venues, players }: Props) {
  const router = useRouter();
  const [sourceTab, setSourceTab] = useState<SourceTab>("screenshots");
  const [screenshots, setScreenshots] = useState<File[]>([]);
  const [documentFile, setDocumentFile] = useState<File | null>(null);
  const [sourceUrl, setSourceUrl] = useState("");
  const [session, setSession] = useState<MatchImportRecord | null>(null);
  const [parsed, setParsed] = useState<ParsedMatchImport | null>(null);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [statusMessage, setStatusMessage] = useState("");

  const importConfidence = parsed?.confidence_score ?? session?.confidence_score ?? 0;
  const warnings = useMemo(() => parsed?.parser_warnings ?? [], [parsed]);

  const processImport = async () => {
    setLoading(true);
    setError("");
    setStatusMessage("");
    try {
      const response =
        sourceTab === "screenshots"
          ? await api.importScreenshots(screenshots)
          : sourceTab === "url"
            ? await api.importUrl(sourceUrl)
            : documentFile
              ? await api.importPdf(documentFile)
              : null;

      if (!response) {
        throw new Error("No import response returned.");
      }
      if (!response.id || !response.parsed_json) {
        throw new Error("Import API returned an empty response. Check the backend URL and Supabase setup.");
      }
      setSession(response);
      setParsed(response.parsed_json || createBlankParsedImport());
      setStatusMessage("Import parsed. Review and correct the extracted data before saving.");
    } catch (importError) {
      setError(importError instanceof Error ? importError.message : "Unable to process the import.");
    } finally {
      setLoading(false);
    }
  };

  const updateMatchDetails = (field: keyof ParsedMatchImport["match_details"], value: string | number | string[] | null) => {
    setParsed((current) => {
      if (!current) return current;
      return {
        ...current,
        match_details: {
          ...current.match_details,
          [field]: value,
        },
      };
    });
  };

  const updateResultField = (field: keyof ParsedMatchImport["result"], value: string | number) => {
    setParsed((current) => {
      if (!current) return current;
      return {
        ...current,
        result: {
          ...current.result,
          [field]: value,
        },
      };
    });
  };

  const updateInningsField = (inningIndex: number, field: keyof ParsedInnings, value: string | number | Record<string, number> | string[] | ParsedBattingRow[] | ParsedBowlingRow[] | ParsedFowRow[]) => {
    setParsed((current) => {
      if (!current) return current;
      const innings = current.innings.map((inning, index) =>
        index === inningIndex
          ? {
              ...inning,
              [field]: value,
            }
          : inning,
      );
      return { ...current, innings };
    });
  };

  const updateBattingRow = (inningIndex: number, rowIndex: number, field: keyof ParsedBattingRow, value: string | number | boolean) => {
    setParsed((current) => {
      if (!current) return current;
      const innings = current.innings.map((inning, index) => {
        if (index !== inningIndex) return inning;
        const batting = inning.batting.map((row, battingIndex) =>
          battingIndex === rowIndex
            ? {
                ...row,
                [field]: value,
              }
            : row,
        );
        return { ...inning, batting };
      });
      return { ...current, innings };
    });
  };

  const updateBowlingRow = (inningIndex: number, rowIndex: number, field: keyof ParsedBowlingRow, value: string | number) => {
    setParsed((current) => {
      if (!current) return current;
      const innings = current.innings.map((inning, index) => {
        if (index !== inningIndex) return inning;
        const bowling = inning.bowling.map((row, bowlingIndex) =>
          bowlingIndex === rowIndex
            ? {
                ...row,
                [field]: value,
              }
            : row,
        );
        return { ...inning, bowling };
      });
      return { ...current, innings };
    });
  };

  const updateFowRow = (inningIndex: number, rowIndex: number, field: keyof ParsedFowRow, value: string | number) => {
    setParsed((current) => {
      if (!current) return current;
      const innings = current.innings.map((inning, index) => {
        if (index !== inningIndex) return inning;
        const fallOfWickets = inning.fall_of_wickets.map((row, fowIndex) =>
          fowIndex === rowIndex
            ? {
                ...row,
                [field]: value,
              }
            : row,
        );
        return { ...inning, fall_of_wickets: fallOfWickets };
      });
      return { ...current, innings };
    });
  };

  const addBattingRow = (inningIndex: number) => {
    setParsed((current) => {
      if (!current) return current;
      const innings = current.innings.map((inning, index) =>
        index === inningIndex
          ? {
              ...inning,
              batting: [
                ...inning.batting,
                {
                  player_name: "",
                  dismissal: "",
                  runs: 0,
                  balls: 0,
                  dots: 0,
                  fours: 0,
                  sixes: 0,
                  strike_rate: 0,
                  is_not_out: false,
                  is_captain: false,
                  is_wicketkeeper: false,
                },
              ],
            }
          : inning,
      );
      return { ...current, innings };
    });
  };

  const addBowlingRow = (inningIndex: number) => {
    setParsed((current) => {
      if (!current) return current;
      const innings = current.innings.map((inning, index) =>
        index === inningIndex
          ? {
              ...inning,
              bowling: [
                ...inning.bowling,
                {
                  player_name: "",
                  overs: 0,
                  maidens: 0,
                  runs_conceded: 0,
                  wickets: 0,
                  dots: 0,
                  wides: 0,
                  no_balls: 0,
                  economy: 0,
                },
              ],
            }
          : inning,
      );
      return { ...current, innings };
    });
  };

  const addFowRow = (inningIndex: number) => {
    setParsed((current) => {
      if (!current) return current;
      const innings = current.innings.map((inning, index) =>
        index === inningIndex
          ? {
              ...inning,
              fall_of_wickets: [
                ...inning.fall_of_wickets,
                {
                  score: 0,
                  wicket_number: 0,
                  player_out: "",
                  over: 0,
                },
              ],
            }
          : inning,
      );
      return { ...current, innings };
    });
  };

  const removeBattingRow = (inningIndex: number, rowIndex: number) => {
    setParsed((current) => {
      if (!current) return current;
      const innings = current.innings.map((inning, index) =>
        index === inningIndex
          ? {
              ...inning,
              batting: inning.batting.filter((_, battingIndex) => battingIndex !== rowIndex),
            }
          : inning,
      );
      return { ...current, innings };
    });
  };

  const removeBowlingRow = (inningIndex: number, rowIndex: number) => {
    setParsed((current) => {
      if (!current) return current;
      const innings = current.innings.map((inning, index) =>
        index === inningIndex
          ? {
              ...inning,
              bowling: inning.bowling.filter((_, bowlingIndex) => bowlingIndex !== rowIndex),
            }
          : inning,
      );
      return { ...current, innings };
    });
  };

  const removeFowRow = (inningIndex: number, rowIndex: number) => {
    setParsed((current) => {
      if (!current) return current;
      const innings = current.innings.map((inning, index) =>
        index === inningIndex
          ? {
              ...inning,
              fall_of_wickets: inning.fall_of_wickets.filter((_, fowIndex) => fowIndex !== rowIndex),
            }
          : inning,
      );
      return { ...current, innings };
    });
  };

  const saveImport = async () => {
    if (!session || !parsed) return;
    setSaving(true);
    setError("");
    try {
      const response = await api.confirmImport({
        import_id: session.id,
        parsed_json: parsed,
      });
      if (!response.match?.id) {
        throw new Error("The backend did not return a saved match.");
      }
      setStatusMessage("Match saved successfully. Redirecting to match detail...");
      router.push(`/matches/${response.match.id}`);
      router.refresh();
      return response;
    } catch (saveError) {
      setError(saveError instanceof Error ? saveError.message : "Unable to save the imported match.");
    } finally {
      setSaving(false);
    }
  };

  const resetWorkflow = () => {
    setSession(null);
    setParsed(null);
    setScreenshots([]);
    setDocumentFile(null);
    setSourceUrl("");
    setStatusMessage("");
    setError("");
  };

  const filePreviewLabel = useMemo(() => {
    if (sourceTab === "screenshots") return screenshots.map((file) => file.name).join(", ");
    if (sourceTab === "pdf") return documentFile?.name || "";
    return sourceUrl;
  }, [documentFile, screenshots, sourceTab, sourceUrl]);

  if (loading) {
    return <Loader label="Extracting scorecard data..." />;
  }

  return (
    <div className="space-y-5">
      <GlassCard className="space-y-4">
        <div className="flex flex-wrap gap-2">
          {sourceTabs.map((tab) => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                type="button"
                onClick={() => setSourceTab(tab.id)}
                className={`flex items-center gap-2 rounded-2xl border px-4 py-3 text-sm font-semibold transition ${
                  sourceTab === tab.id
                    ? "border-violet-300/40 bg-violet-400/15 text-violet-100"
                    : "border-white/10 bg-white/5 text-slate-300 hover:border-violet-300/30 hover:text-white"
                }`}
              >
                <Icon className="h-4 w-4" />
                {tab.label}
              </button>
            );
          })}
        </div>

        <div className="rounded-2xl border border-white/10 bg-slate-950/40 px-4 py-3 text-sm text-slate-300">
          Current database references: <span className="text-white">{teams.length}</span> teams,{" "}
          <span className="text-white">{venues.length}</span> venues, <span className="text-white">{players.length}</span> players.
        </div>

        {sourceTab === "screenshots" && (
          <DropZone
            label="Drop scorecard screenshots here"
            helper="Upload multiple images for batting cards, bowling cards, and match details."
            accept="image/*"
            multiple
            onFilesSelected={(files) => setScreenshots(files)}
            files={screenshots}
          />
        )}

        {sourceTab === "url" && (
          <div className="grid gap-3 md:grid-cols-[1fr_auto]">
            <label className="block">
              <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">Public scorecard URL</span>
              <input
                value={sourceUrl}
                onChange={(event) => setSourceUrl(event.target.value)}
                placeholder="https://..."
                className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-violet-300/50"
              />
            </label>
            <div className="flex items-end">
              <NeonButton onClick={processImport} loading={loading} disabled={!sourceUrl}>
                Fetch Scorecard
              </NeonButton>
            </div>
          </div>
        )}

        {sourceTab === "pdf" && (
          <DropZone
            label="Drop scorecard PDF or image"
            helper="Scanned PDFs are supported. Images are OCR-ready."
            accept="image/*,.pdf"
            onFilesSelected={(files) => setDocumentFile(files[0] || null)}
            files={documentFile ? [documentFile] : []}
            single
          />
        )}

        {sourceTab !== "url" && (
          <div className="flex flex-wrap items-center gap-3">
            <NeonButton
              onClick={processImport}
              loading={loading}
              disabled={(sourceTab === "screenshots" && screenshots.length === 0) || (sourceTab === "pdf" && !documentFile)}
            >
              Process Import
            </NeonButton>
            <p className="text-sm text-slate-400">{filePreviewLabel || "No files selected yet."}</p>
          </div>
        )}
      </GlassCard>

      {error && <ErrorState message={error} onRetry={session ? saveImport : processImport} />}

      {!session && !error && !statusMessage && (
      <EmptyState title="No import processed yet" description="Upload screenshots, paste a public scorecard URL, or use a PDF/image to extract match data." />
      )}

      {session && parsed && (
        <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.3 }} className="space-y-5">
          <GlassCard>
            <div className="flex flex-wrap items-center justify-between gap-3">
              <div>
                <p className="text-xs uppercase tracking-[0.24em] text-slate-400">Import Review</p>
                <h2 className="mt-1 text-2xl font-semibold text-white">Confirm extracted match data</h2>
              </div>
              <div className="rounded-2xl border border-violet-300/20 bg-violet-400/10 px-4 py-3 text-right">
                <p className="text-xs uppercase tracking-[0.24em] text-slate-400">Confidence</p>
                <p className="text-2xl font-semibold text-violet-100">{Math.round(importConfidence * 100)}%</p>
              </div>
            </div>
          </GlassCard>

          <div className="grid gap-5 xl:grid-cols-2">
            <GlassCard className="space-y-4">
              <SectionTitle icon={Sparkles} title="Match details" subtitle="Edit extracted metadata before saving." />
              <FieldRow label="Venue" value={parsed.match_details.venue} onChange={(value) => updateMatchDetails("venue", value)} />
              <FieldRow label="City" value={parsed.match_details.city} onChange={(value) => updateMatchDetails("city", value)} />
              <FieldRow label="Match date" type="date" value={parsed.match_details.match_date} onChange={(value) => updateMatchDetails("match_date", value)} />
              <FieldRow label="Match time" value={parsed.match_details.match_time} onChange={(value) => updateMatchDetails("match_time", value)} />
              <FieldRow label="Match number" type="number" value={parsed.match_details.match_number ?? ""} onChange={(value) => updateMatchDetails("match_number", Number(value || 0))} />
              <FieldRow label="Toss winner" value={parsed.match_details.toss_winner} onChange={(value) => updateMatchDetails("toss_winner", value)} />
              <FieldRow label="Toss decision" value={parsed.match_details.toss_decision} onChange={(value) => updateMatchDetails("toss_decision", value)} />
              <FieldRow label="Player of the match" value={parsed.match_details.player_of_match} onChange={(value) => updateMatchDetails("player_of_match", value)} />
              <div>
                <p className="mb-2 text-xs uppercase tracking-[0.24em] text-slate-400">Umpires</p>
                <textarea
                  value={parsed.match_details.umpires.join(", ")}
                  onChange={(event) => updateMatchDetails("umpires", event.target.value.split(",").map((item) => item.trim()).filter(Boolean))}
                  rows={3}
                  className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-violet-300/50"
                />
              </div>
            </GlassCard>

            <GlassCard className="space-y-4">
              <SectionTitle icon={ScanSearch} title="Warnings" subtitle="Review these before saving." />
              {warnings.length > 0 ? (
                <div className="space-y-2">
                  {warnings.map((warning) => (
                    <div key={warning} className="flex gap-3 rounded-2xl border border-amber-300/20 bg-amber-400/10 px-4 py-3 text-sm text-amber-50">
                      <TriangleAlert className="mt-0.5 h-4 w-4 shrink-0" />
                      <span>{warning}</span>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="rounded-2xl border border-emerald-300/20 bg-emerald-400/10 px-4 py-3 text-sm text-emerald-50">
                  No parser warnings at the moment.
                </p>
              )}

              <div className="rounded-3xl border border-white/10 bg-white/5 p-4 text-sm text-slate-300">
                <p className="font-semibold text-white">Matching guidance</p>
                <ul className="mt-2 space-y-2">
                  <li>• Teams are matched against your current database by name.</li>
                  <li>• Players are created automatically when a name does not exist.</li>
                  <li>• Final save runs server-side validation again.</li>
                </ul>
              </div>
            </GlassCard>
          </div>

          {parsed.innings.map((inning, inningIndex) => (
            <GlassCard key={`${inning.team_name || inningIndex}-${inningIndex}`} className="space-y-5">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <SectionTitle
                  icon={Sparkles}
                  title={`Innings ${inningIndex + 1}`}
                  subtitle="Edit scores, batting, bowling, and fall of wickets."
                />
                <div className="flex flex-wrap gap-2 text-xs text-slate-300">
                  <Badge>Score {inning.score}</Badge>
                  <Badge>Wkts {inning.wickets}</Badge>
                  <Badge>Overs {inning.overs}</Badge>
                </div>
              </div>

              <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
                <FieldRow label="Team name" value={inning.team_name} onChange={(value) => updateInningsField(inningIndex, "team_name", value)} />
                <FieldRow label="Score" type="number" value={inning.score} onChange={(value) => updateInningsField(inningIndex, "score", Number(value))} />
                <FieldRow label="Wickets" type="number" value={inning.wickets} onChange={(value) => updateInningsField(inningIndex, "wickets", Number(value))} />
                <FieldRow label="Overs" type="number" step="0.1" value={inning.overs} onChange={(value) => updateInningsField(inningIndex, "overs", Number(value))} />
                <FieldRow label="Run rate" type="number" step="0.01" value={inning.run_rate} onChange={(value) => updateInningsField(inningIndex, "run_rate", Number(value))} />
                <FieldRow label="Extras" type="number" value={inning.extras} onChange={(value) => updateInningsField(inningIndex, "extras", Number(value))} />
                <FieldRow
                  label="Extras breakdown JSON"
                  value={JSON.stringify(inning.extras_breakdown || {})}
                  onChange={(value) => {
                    try {
                      updateInningsField(inningIndex, "extras_breakdown", JSON.parse(value || "{}"));
                    } catch {
                      updateInningsField(inningIndex, "extras_breakdown", inning.extras_breakdown);
                    }
                  }}
                />
              </div>

              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <SectionTitle title="Batting table" subtitle="Edit player rows and dismissal details." />
                  <NeonButton onClick={() => addBattingRow(inningIndex)}>Add batter</NeonButton>
                </div>
                <EditableBattingTable
                  rows={inning.batting}
                  onDelete={(rowIndex) => removeBattingRow(inningIndex, rowIndex)}
                  onChange={(rowIndex, field, value) => updateBattingRow(inningIndex, rowIndex, field, value)}
                />
              </div>

              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <SectionTitle title="Bowling table" subtitle="Edit bowling figures and economy." />
                  <NeonButton onClick={() => addBowlingRow(inningIndex)}>Add bowler</NeonButton>
                </div>
                <EditableBowlingTable
                  rows={inning.bowling}
                  onDelete={(rowIndex) => removeBowlingRow(inningIndex, rowIndex)}
                  onChange={(rowIndex, field, value) => updateBowlingRow(inningIndex, rowIndex, field, value)}
                />
              </div>

              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <SectionTitle title="Fall of wickets" subtitle="Edit wicket progression." />
                  <NeonButton onClick={() => addFowRow(inningIndex)}>Add wicket</NeonButton>
                </div>
                {inning.fall_of_wickets.length === 0 ? (
                  <p className="rounded-2xl border border-dashed border-white/15 bg-white/5 px-4 py-3 text-sm text-slate-400">No fall-of-wickets rows detected.</p>
                ) : (
                  <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-4">
                    {inning.fall_of_wickets.map((row, rowIndex) => (
                      <div key={`${rowIndex}-${row.player_out}`} className="rounded-3xl border border-white/10 bg-slate-950/40 p-4">
                        <FieldRow label="Score" type="number" value={row.score} onChange={(value) => updateFowRow(inningIndex, rowIndex, "score", Number(value))} />
                        <FieldRow label="Wicket number" type="number" value={row.wicket_number} onChange={(value) => updateFowRow(inningIndex, rowIndex, "wicket_number", Number(value))} />
                        <FieldRow label="Player out" value={row.player_out} onChange={(value) => updateFowRow(inningIndex, rowIndex, "player_out", value)} />
                        <FieldRow label="Over" type="number" step="0.1" value={row.over} onChange={(value) => updateFowRow(inningIndex, rowIndex, "over", Number(value))} />
                        <div className="mt-3">
                          <NeonButton onClick={() => removeFowRow(inningIndex, rowIndex)}>Remove</NeonButton>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              <div className="grid gap-4 md:grid-cols-2">
                <div>
                  <p className="mb-2 text-xs uppercase tracking-[0.24em] text-slate-400">Yet to bat</p>
                  <textarea
                    value={inning.yet_to_bat.join(", ")}
                    onChange={(event) =>
                      updateInningsField(
                        inningIndex,
                        "yet_to_bat",
                        event.target.value
                          .split(",")
                          .map((item) => item.trim())
                          .filter(Boolean),
                      )
                    }
                    rows={3}
                    className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-violet-300/50"
                  />
                </div>
                <div>
                  <p className="mb-2 text-xs uppercase tracking-[0.24em] text-slate-400">Imported team notes</p>
                  <div className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-slate-300">
                    The importer will create or match players on save. Edit the tables above if the OCR missed a name.
                  </div>
                </div>
              </div>
            </GlassCard>
          ))}

          <GlassCard className="space-y-4">
            <SectionTitle icon={Sparkles} title="Save import" subtitle="Confirm only after checking the extracted rows." />
            <div className="flex flex-wrap gap-3">
              <NeonButton onClick={saveImport} loading={saving}>
                Save Match
              </NeonButton>
              <NeonButton onClick={resetWorkflow} className="border-white/15 bg-white/5 text-white">
                Cancel
              </NeonButton>
            </div>
          </GlassCard>
        </motion.div>
      )}

      {statusMessage && !session && !parsed && (
        <div className="rounded-3xl border border-emerald-300/20 bg-emerald-400/10 px-4 py-3 text-sm text-emerald-50">
          {statusMessage}
        </div>
      )}
    </div>
  );
}

function DropZone({
  label,
  helper,
  accept,
  multiple = false,
  single = false,
  files,
  onFilesSelected,
}: {
  label: string;
  helper: string;
  accept: string;
  multiple?: boolean;
  single?: boolean;
  files: File[];
  onFilesSelected: (files: File[]) => void;
}) {
  return (
    <div
      onDragOver={(event) => event.preventDefault()}
      onDrop={(event) => {
        event.preventDefault();
        onFilesSelected(Array.from(event.dataTransfer.files));
      }}
      className="rounded-3xl border border-dashed border-white/15 bg-white/5 p-5 text-center"
    >
      <input
        type="file"
        accept={accept}
        multiple={multiple}
        onChange={(event) => onFilesSelected(Array.from(event.target.files || []))}
        className="hidden"
        id={`file-upload-${label.replace(/\s+/g, "-").toLowerCase()}`}
      />
      <label htmlFor={`file-upload-${label.replace(/\s+/g, "-").toLowerCase()}`} className="cursor-pointer">
        <div className="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-violet-400/15 text-violet-100">
          <CloudUpload className="h-6 w-6" />
        </div>
        <p className="mt-4 text-lg font-semibold text-white">{label}</p>
        <p className="mt-2 text-sm text-slate-400">{helper}</p>
        <p className="mt-3 text-xs uppercase tracking-[0.24em] text-slate-500">{single ? "Single file" : "Multiple files allowed"}</p>
      </label>
      {files.length > 0 && (
        <div className="mt-4 flex flex-wrap justify-center gap-2">
          {files.map((file) => (
            <span key={file.name} className="rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs text-slate-300">
              {file.name}
            </span>
          ))}
        </div>
      )}
    </div>
  );
}

function FieldRow({
  label,
  value,
  onChange,
  type = "text",
  step,
}: {
  label: string;
  value: string | number;
  onChange: (value: string) => void;
  type?: string;
  step?: string;
}) {
  return (
    <label className="block">
      <span className="mb-2 block text-xs uppercase tracking-[0.24em] text-slate-400">{label}</span>
      <input
        type={type}
        step={step}
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="w-full rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none focus:border-violet-300/50"
      />
    </label>
  );
}

function EditableBattingTable({
  rows,
  onChange,
  onDelete,
}: {
  rows: ParsedBattingRow[];
  onChange: (rowIndex: number, field: keyof ParsedBattingRow, value: string | number | boolean) => void;
  onDelete: (rowIndex: number) => void;
}) {
  if (rows.length === 0) {
    return <p className="rounded-2xl border border-dashed border-white/15 bg-white/5 px-4 py-3 text-sm text-slate-400">No batting rows extracted yet.</p>;
  }

  return (
    <div className="overflow-hidden rounded-3xl border border-white/10">
      <table className="min-w-full text-sm">
        <thead className="bg-white/5 text-xs uppercase tracking-[0.24em] text-slate-400">
          <tr>
            <th className="px-3 py-3 text-left">Player</th>
            <th className="px-3 py-3 text-left">Dismissal</th>
            <th className="px-3 py-3">R</th>
            <th className="px-3 py-3">B</th>
            <th className="px-3 py-3">Dots</th>
            <th className="px-3 py-3">4s</th>
            <th className="px-3 py-3">6s</th>
            <th className="px-3 py-3">SR</th>
            <th className="px-3 py-3">Flags</th>
            <th className="px-3 py-3">Action</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row, rowIndex) => (
            <tr key={`${rowIndex}-${row.player_name}`} className="border-t border-white/10">
              <td className="px-3 py-2">
                <input value={row.player_name} onChange={(event) => onChange(rowIndex, "player_name", event.target.value)} className="w-full rounded-xl border border-white/10 bg-slate-950/60 px-3 py-2 text-white" />
              </td>
              <td className="px-3 py-2">
                <input value={row.dismissal} onChange={(event) => onChange(rowIndex, "dismissal", event.target.value)} className="w-full rounded-xl border border-white/10 bg-slate-950/60 px-3 py-2 text-white" />
              </td>
              {(["runs", "balls", "dots", "fours", "sixes", "strike_rate"] as const).map((field) => (
                <td key={field} className="px-3 py-2">
                  <input
                    type="number"
                    step={field === "strike_rate" ? "0.01" : "1"}
                    value={row[field]}
                    onChange={(event) => onChange(rowIndex, field, Number(event.target.value))}
                    className="w-20 rounded-xl border border-white/10 bg-slate-950/60 px-3 py-2 text-center text-white"
                  />
                </td>
              ))}
              <td className="px-3 py-2">
                <div className="flex flex-wrap gap-2 text-xs">
                  <FlagPill active={row.is_not_out} label="NO" onToggle={() => onChange(rowIndex, "is_not_out", !row.is_not_out)} />
                  <FlagPill active={row.is_captain} label="C" onToggle={() => onChange(rowIndex, "is_captain", !row.is_captain)} />
                  <FlagPill active={row.is_wicketkeeper} label="WK" onToggle={() => onChange(rowIndex, "is_wicketkeeper", !row.is_wicketkeeper)} />
                </div>
              </td>
              <td className="px-3 py-2">
                <NeonButton onClick={() => onDelete(rowIndex)}>Remove</NeonButton>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function EditableBowlingTable({
  rows,
  onChange,
  onDelete,
}: {
  rows: ParsedBowlingRow[];
  onChange: (rowIndex: number, field: keyof ParsedBowlingRow, value: string | number) => void;
  onDelete: (rowIndex: number) => void;
}) {
  if (rows.length === 0) {
    return <p className="rounded-2xl border border-dashed border-white/15 bg-white/5 px-4 py-3 text-sm text-slate-400">No bowling rows extracted yet.</p>;
  }

  return (
    <div className="overflow-hidden rounded-3xl border border-white/10">
      <table className="min-w-full text-sm">
        <thead className="bg-white/5 text-xs uppercase tracking-[0.24em] text-slate-400">
          <tr>
            <th className="px-3 py-3 text-left">Player</th>
            <th className="px-3 py-3">O</th>
            <th className="px-3 py-3">M</th>
            <th className="px-3 py-3">R</th>
            <th className="px-3 py-3">W</th>
            <th className="px-3 py-3">Dots</th>
            <th className="px-3 py-3">Wd</th>
            <th className="px-3 py-3">Nb</th>
            <th className="px-3 py-3">Econ</th>
            <th className="px-3 py-3">Action</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row, rowIndex) => (
            <tr key={`${rowIndex}-${row.player_name}`} className="border-t border-white/10">
              <td className="px-3 py-2">
                <input value={row.player_name} onChange={(event) => onChange(rowIndex, "player_name", event.target.value)} className="w-full rounded-xl border border-white/10 bg-slate-950/60 px-3 py-2 text-white" />
              </td>
              {(["overs", "maidens", "runs_conceded", "wickets", "dots", "wides", "no_balls", "economy"] as const).map((field) => (
                <td key={field} className="px-3 py-2">
                  <input
                    type="number"
                    step={field === "overs" || field === "economy" ? "0.1" : "1"}
                    value={row[field]}
                    onChange={(event) => onChange(rowIndex, field, Number(event.target.value))}
                    className="w-20 rounded-xl border border-white/10 bg-slate-950/60 px-3 py-2 text-center text-white"
                  />
                </td>
              ))}
              <td className="px-3 py-2">
                <NeonButton onClick={() => onDelete(rowIndex)}>Remove</NeonButton>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function SectionTitle({
  title,
  subtitle,
  icon: Icon,
}: {
  title: string;
  subtitle?: string;
  icon?: ComponentType<{ className?: string }>;
}) {
  return (
    <div>
      <div className="flex items-center gap-2">
        {Icon ? <Icon className="h-4 w-4 text-violet-200" /> : null}
        <h3 className="text-lg font-semibold text-white">{title}</h3>
      </div>
      {subtitle && <p className="mt-1 text-sm text-slate-400">{subtitle}</p>}
    </div>
  );
}

function Badge({ children }: { children: ReactNode }) {
  return <span className="rounded-full border border-white/10 bg-white/5 px-3 py-1">{children}</span>;
}

function FlagPill({
  label,
  active,
  onToggle,
}: {
  label: string;
  active: boolean;
  onToggle: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onToggle}
      className={`rounded-full px-3 py-1 font-semibold transition ${active ? "bg-violet-400/20 text-violet-100" : "bg-white/5 text-slate-300"}`}
    >
      {label}
    </button>
  );
}
