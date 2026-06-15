"use client";

import { motion } from "framer-motion";
import { ArrowUpRight, ArrowDownRight } from "lucide-react";
import { GlassCard } from "@/components/ui/GlassCard";
import { cn } from "@/lib/utils";

type KPICardProps = {
  label: string;
  value: string | number;
  trend?: string;
  trendDirection?: "up" | "down" | "flat";
  icon?: React.ReactNode;
  theme?: {
    primary: string;
    secondary: string;
    accent: string;
    gradient: string;
    glow: string;
    border: string;
  };
};

export function KPICard({ label, value, trend, trendDirection = "flat", icon, theme }: KPICardProps) {
  const trendColor = trendDirection === "up" ? "text-emerald-300" : trendDirection === "down" ? "text-rose-300" : "text-slate-300";
  return (
    <motion.div whileHover={{ y: -4 }}>
      <GlassCard
        className={cn(
          "relative overflow-hidden",
          theme ? "border-opacity-60" : "",
        )}
      >
        <div
          className="absolute inset-0 opacity-70"
          style={{
            background: theme?.gradient || "linear-gradient(135deg, rgba(56,189,248,0.12), rgba(168,85,247,0.10))",
          }}
        />
        <div
          className="absolute inset-0"
          style={{
            boxShadow: theme ? `0 0 28px ${theme.glow}` : undefined,
          }}
        />
        <div className="relative flex items-start justify-between gap-4">
          <div>
            <p className="text-xs uppercase tracking-[0.28em] text-slate-300/80">{label}</p>
            <div className="mt-2 text-3xl font-semibold text-white">{value}</div>
            {trend && (
              <p className={cn("mt-2 flex items-center gap-1 text-sm", trendColor)}>
                {trendDirection === "up" ? <ArrowUpRight className="h-4 w-4" /> : trendDirection === "down" ? <ArrowDownRight className="h-4 w-4" /> : null}
                {trend}
              </p>
            )}
          </div>
          {icon && <div className="rounded-2xl border border-white/10 bg-white/10 p-3 text-white">{icon}</div>}
        </div>
      </GlassCard>
    </motion.div>
  );
}
