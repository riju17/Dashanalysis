"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { motion } from "framer-motion";
import { ChevronLeft, ChevronRight, Orbit } from "lucide-react";
import { navItems } from "@/config/navItems";
import { cn } from "@/lib/utils";

type SidebarProps = {
  collapsed: boolean;
  onToggle: () => void;
};

export function Sidebar({ collapsed, onToggle }: SidebarProps) {
  const pathname = usePathname();

  return (
    <aside
      className={cn(
        "sticky top-0 flex h-screen flex-col border-r border-white/10 bg-slate-950/75 px-3 py-4 backdrop-blur-2xl transition-all duration-300",
        collapsed ? "w-20" : "w-72",
      )}
    >
      <div className="flex items-center justify-between gap-3 px-2">
        <div className="flex items-center gap-3">
          <div className="grid h-11 w-11 place-items-center rounded-2xl bg-gradient-to-br from-cyan-400 via-blue-500 to-violet-500 text-white shadow-neon">
            <Orbit className="h-5 w-5" />
          </div>
          {!collapsed && (
            <div>
              <p className="text-xs uppercase tracking-[0.35em] text-cyan-300/80">StatStrike</p>
              <h1 className="text-lg font-semibold text-white">Match Intelligence</h1>
            </div>
          )}
        </div>
        <button
          onClick={onToggle}
          className="rounded-xl border border-white/10 bg-white/5 p-2 text-slate-200 transition hover:border-cyan-300/40 hover:bg-white/10"
        >
          {collapsed ? <ChevronRight className="h-4 w-4" /> : <ChevronLeft className="h-4 w-4" />}
        </button>
      </div>

      <nav className="mt-6 flex-1 space-y-1 overflow-y-auto pb-4">
        {navItems.map((item) => {
          const active = pathname === item.href;
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "group flex items-center gap-3 rounded-2xl px-3 py-3 text-sm font-medium transition",
                active
                  ? "border border-cyan-300/30 bg-cyan-400/10 text-white shadow-[0_0_24px_rgba(34,211,238,0.16)]"
                  : "text-slate-300 hover:bg-white/5 hover:text-white",
              )}
            >
              <span
                className={cn(
                  "grid h-9 w-9 place-items-center rounded-xl transition",
                  active ? "bg-cyan-300/15 text-cyan-200" : "bg-white/5 text-slate-300 group-hover:text-cyan-200",
                )}
              >
                <Icon className="h-4 w-4" />
              </span>
              {!collapsed && <span>{item.label}</span>}
            </Link>
          );
        })}
      </nav>

      {!collapsed && (
        <div className="rounded-3xl border border-cyan-300/15 bg-white/5 p-4 text-xs text-slate-300">
          <p className="font-semibold text-cyan-200">Analyst War Room</p>
          <p className="mt-1">Rule-based intelligence, venue patterns, player impact, and match reports in one place.</p>
        </div>
      )}
    </aside>
  );
}
