"use client";

import { AlertTriangle } from "lucide-react";
import { NeonButton } from "@/components/ui/NeonButton";

type ErrorStateProps = {
  message: string;
  onRetry?: () => void;
};

export function ErrorState({ message, onRetry }: ErrorStateProps) {
  return (
    <div className="rounded-3xl border border-red-400/30 bg-red-500/10 p-5 text-sm text-red-100 backdrop-blur-xl">
      <div className="flex items-center gap-2 font-semibold">
        <AlertTriangle className="h-4 w-4" />
        <span>Unable to load intelligence</span>
      </div>
      <p className="mt-2 text-red-100/80">{message}</p>
      {onRetry && (
        <div className="mt-4">
          <NeonButton onClick={onRetry}>Retry</NeonButton>
        </div>
      )}
    </div>
  );
}
