"use client";

import { useState } from "react";
import { api } from "@/lib/api";
import { GlassCard } from "@/components/ui/GlassCard";
import { NeonButton } from "@/components/ui/NeonButton";

export function TeamForm({ onSaved }: { onSaved?: () => void }) {
  const [form, setForm] = useState({ team_name: "", short_name: "", primary_color: "", secondary_color: "", accent_color: "", logo_url: "" });
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  const submit = async () => {
    setLoading(true);
    setMessage("");
    try {
      await api.createTeam(form);
      setMessage("Team saved.");
      onSaved?.();
      setForm({ team_name: "", short_name: "", primary_color: "", secondary_color: "", accent_color: "", logo_url: "" });
    } finally {
      setLoading(false);
    }
  };

  return (
    <GlassCard>
      <div className="grid gap-3 md:grid-cols-2">
        {["team_name", "short_name", "primary_color", "secondary_color", "accent_color", "logo_url"].map((field) => (
          <input
            key={field}
            value={(form as any)[field]}
            onChange={(e) => setForm((current) => ({ ...current, [field]: e.target.value }))}
            placeholder={field.replaceAll("_", " ")}
            className="rounded-2xl border border-white/10 bg-slate-950/70 px-4 py-3 text-sm text-white outline-none placeholder:text-slate-500 focus:border-cyan-300/50"
          />
        ))}
      </div>
      <div className="mt-4 flex items-center gap-3">
        <NeonButton loading={loading} onClick={submit}>Save team</NeonButton>
        {message && <p className="text-sm text-emerald-300">{message}</p>}
      </div>
    </GlassCard>
  );
}
