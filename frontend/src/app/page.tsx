"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { ArrowRight, Sparkles, Shield, Trophy, Radar } from "lucide-react";
import { GlassCard } from "@/components/ui/GlassCard";
import { NeonButton } from "@/components/ui/NeonButton";
import { teamThemes } from "@/config/teamThemes";

const featuredTeams = Object.values(teamThemes).slice(0, 4);

export default function HomePage() {
  return (
    <div className="min-h-screen px-4 py-6 text-white md:px-8">
      <div className="mx-auto max-w-7xl">
        <motion.div
          initial={{ opacity: 0, y: 18 }}
          animate={{ opacity: 1, y: 0 }}
          className="overflow-hidden rounded-[2rem] border border-white/10 bg-white/5 p-8 backdrop-blur-2xl md:p-12"
        >
          <div className="grid gap-8 lg:grid-cols-[1.4fr_0.9fr] lg:items-center">
            <div>
              <p className="text-xs uppercase tracking-[0.45em] text-cyan-300/80">StatStrike Match Intelligence Engine</p>
              <h1 className="mt-4 max-w-3xl text-4xl font-semibold leading-tight md:text-6xl">
                Broadcast-grade cricket analytics for analysts, coaches, and franchise operations.
              </h1>
              <p className="mt-5 max-w-2xl text-base text-slate-300 md:text-lg">
                Enter completed matches, track player impact, understand venue behaviour, and generate strategy-ready reports with a futuristic sports command center.
              </p>
              <div className="mt-8 flex flex-wrap gap-3">
                <Link href="/dashboard">
                  <NeonButton>
                    Open dashboard <ArrowRight className="h-4 w-4" />
                  </NeonButton>
                </Link>
                <Link href="/add-match">
                  <NeonButton className="bg-white/10">Log a match</NeonButton>
                </Link>
              </div>
              <div className="mt-8 grid gap-3 sm:grid-cols-3">
                {[
                  ["10 Teams", "theme engine"],
                  ["Rule-based", "prediction engine"],
                  ["FastAPI", "backend + analytics"],
                ].map(([headline, sub]) => (
                  <GlassCard key={headline} className="p-4">
                    <p className="text-lg font-semibold text-white">{headline}</p>
                    <p className="mt-1 text-sm text-slate-400">{sub}</p>
                  </GlassCard>
                ))}
              </div>
            </div>
            <div className="grid gap-4">
              {featuredTeams.map((team) => (
                <GlassCard key={team.teamName} className="relative overflow-hidden">
                  <div className="absolute inset-0 opacity-80" style={{ background: team.gradient }} />
                  <div className="relative flex items-center justify-between gap-4">
                    <div>
                      <p className="text-xs uppercase tracking-[0.35em] text-white/80">{team.teamName}</p>
                      <p className="mt-2 text-sm text-white/90">Dynamic theme with glow, gradient, and HUD-style treatment.</p>
                    </div>
                    <div className="rounded-2xl border border-white/20 bg-white/10 p-3">
                      <Sparkles className="h-5 w-5 text-white" />
                    </div>
                  </div>
                </GlassCard>
              ))}
            </div>
          </div>
        </motion.div>

        <div className="mt-8 grid gap-4 md:grid-cols-3">
          {[
            { icon: Trophy, title: "Analyst dashboards", text: "Match intelligence, team signals, venue scoring, and player impact." },
            { icon: Shield, title: "Opponent strategy", text: "Toss guidance, target setting, phase planning, and matchup notes." },
            { icon: Radar, title: "Futuristic UX", text: "Glassmorphism, neon borders, motion, and broadcast-grade visuals." },
          ].map((item) => (
            <GlassCard key={item.title} className="p-5">
              <item.icon className="h-6 w-6 text-cyan-300" />
              <h3 className="mt-4 text-lg font-semibold text-white">{item.title}</h3>
              <p className="mt-2 text-sm text-slate-400">{item.text}</p>
            </GlassCard>
          ))}
        </div>
      </div>
    </div>
  );
}
