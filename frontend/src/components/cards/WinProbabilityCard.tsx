"use client";

import { motion } from "framer-motion";
import { GlassCard } from "@/components/ui/GlassCard";
import { cn } from "@/lib/utils";

type Props = {
  teamALabel: string;
  teamAValue: number;
  teamBLabel: string;
  teamBValue: number;
  theme?: { ringGradient: string; primary: string; accent: string };
};

export function WinProbabilityCard({ teamALabel, teamAValue, teamBLabel, teamBValue, theme }: Props) {
  return (
    <GlassCard className="relative overflow-hidden">
      <div className="grid gap-6 lg:grid-cols-[220px_1fr]">
        <div className="flex items-center justify-center">
          <motion.div
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ duration: 0.4 }}
            className="relative grid h-44 w-44 place-items-center rounded-full"
            style={{ background: theme?.ringGradient || "conic-gradient(from 180deg, #22D3EE, #A855F7, #22D3EE)" }}
          >
            <div className="grid h-28 w-28 place-items-center rounded-full border border-white/10 bg-slate-950/95 text-center shadow-inner">
              <div>
                <p className="text-xs uppercase tracking-[0.3em] text-slate-400">Model</p>
                <p className="text-3xl font-semibold text-white">{teamAValue > teamBValue ? teamAValue : teamBValue}%</p>
              </div>
            </div>
          </motion.div>
        </div>
        <div className="space-y-4">
          <div>
            <p className="text-xs uppercase tracking-[0.3em] text-cyan-200/70">Win Probability</p>
            <h3 className="mt-2 text-2xl font-semibold text-white">Rule-based prediction engine</h3>
            <p className="mt-2 text-sm text-slate-400">
              Probability is derived from team form, venue behaviour, toss decision value, head-to-head data, and strength score.
            </p>
          </div>
          <div className="grid gap-3 md:grid-cols-2">
            <ProbabilityBar label={teamALabel} value={teamAValue} color="from-cyan-400 via-blue-500 to-violet-500" />
            <ProbabilityBar label={teamBLabel} value={teamBValue} color="from-fuchsia-500 via-rose-500 to-orange-400" />
          </div>
        </div>
      </div>
    </GlassCard>
  );
}

function ProbabilityBar({ label, value, color }: { label: string; value: number; color: string }) {
  return (
    <div className="rounded-2xl border border-white/10 bg-white/5 p-4">
      <div className="flex items-center justify-between text-sm">
        <span className="font-medium text-white">{label}</span>
        <span className="text-slate-300">{value.toFixed(1)}%</span>
      </div>
      <div className="mt-3 h-2 overflow-hidden rounded-full bg-white/10">
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: `${value}%` }}
          transition={{ duration: 0.6 }}
          className={cn("h-full rounded-full bg-gradient-to-r", color)}
        />
      </div>
    </div>
  );
}
