import { teamThemes, getTeamTheme } from "@/config/teamThemes";
import type { Team } from "@/types/cricket";
import clsx from "clsx";

export const cn = (...inputs: Array<string | undefined | false | null>) => clsx(inputs);

export const formatNumber = (value?: number | null) =>
  typeof value === "number" ? new Intl.NumberFormat("en-IN").format(value) : "-";

export const formatPercent = (value?: number | null) =>
  typeof value === "number" ? `${value.toFixed(1)}%` : "-";

export const formatDate = (value?: string | null) =>
  value ? new Date(value).toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" }) : "-";

export const themeStyles = (teamName?: string | null) => {
  const theme = getTeamTheme(teamName);
  return {
    backgroundImage: theme.gradient,
    boxShadow: `0 0 24px ${theme.glow}`,
    borderColor: theme.border,
  };
};

export const teamOptions = Object.values(teamThemes).map((theme) => theme.teamName);

export const getTeamLabel = (team?: Team | null) => team?.team_name ?? "No team selected";

export const percentageLabel = (value: number) => `${value.toFixed(0)}%`;
