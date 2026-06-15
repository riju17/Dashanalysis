"use client";

import { Search, Bell, Radar } from "lucide-react";
import { NeonButton } from "@/components/ui/NeonButton";

type TopbarProps = {
  title: string;
  subtitle?: string;
  actionLabel?: string;
  onAction?: () => void;
};

export function Topbar({ title, subtitle, actionLabel, onAction }: TopbarProps) {
  return (
    <header className="flex flex-col gap-4 border-b border-white/10 bg-slate-950/35 px-5 py-4 backdrop-blur-xl md:flex-row md:items-center md:justify-between">
      <div>
        <p className="text-xs uppercase tracking-[0.35em] text-cyan-300/70">Cricket Intelligence Engine</p>
        <h2 className="mt-1 text-2xl font-semibold text-white">{title}</h2>
        {subtitle && <p className="mt-1 max-w-3xl text-sm text-slate-400">{subtitle}</p>}
      </div>
      <div className="flex flex-wrap items-center gap-3">
        <button className="rounded-2xl border border-white/10 bg-white/5 p-3 text-slate-300 transition hover:border-cyan-300/40 hover:text-white">
          <Search className="h-4 w-4" />
        </button>
        <button className="rounded-2xl border border-white/10 bg-white/5 p-3 text-slate-300 transition hover:border-cyan-300/40 hover:text-white">
          <Bell className="h-4 w-4" />
        </button>
        <button className="rounded-2xl border border-white/10 bg-white/5 p-3 text-slate-300 transition hover:border-cyan-300/40 hover:text-white">
          <Radar className="h-4 w-4" />
        </button>
        {actionLabel && onAction && <NeonButton onClick={onAction}>{actionLabel}</NeonButton>}
      </div>
    </header>
  );
}
