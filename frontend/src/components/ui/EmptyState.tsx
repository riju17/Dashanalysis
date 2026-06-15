"use client";

import { motion } from "framer-motion";
import { NeonButton } from "@/components/ui/NeonButton";

type EmptyStateProps = {
  title: string;
  description: string;
  actionLabel?: string;
  onAction?: () => void;
};

export function EmptyState({ title, description, actionLabel, onAction }: EmptyStateProps) {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.98 }}
      animate={{ opacity: 1, scale: 1 }}
      className="rounded-3xl border border-dashed border-white/15 bg-white/5 p-8 text-center backdrop-blur-xl"
    >
      <h3 className="text-lg font-semibold text-white">{title}</h3>
      <p className="mt-2 text-sm text-slate-400">{description}</p>
      {actionLabel && onAction && (
        <div className="mt-4">
          <NeonButton onClick={onAction}>{actionLabel}</NeonButton>
        </div>
      )}
    </motion.div>
  );
}
