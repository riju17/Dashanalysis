export function Loader({ label = "Loading intelligence..." }: { label?: string }) {
  return (
    <div className="flex items-center gap-3 rounded-2xl border border-cyan-300/20 bg-white/5 px-4 py-3 text-sm text-slate-300 backdrop-blur-xl">
      <span className="h-3 w-3 animate-pulse rounded-full bg-cyan-300 shadow-[0_0_18px_rgba(34,211,238,0.8)]" />
      <span>{label}</span>
    </div>
  );
}
