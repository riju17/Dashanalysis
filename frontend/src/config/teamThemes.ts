export type TeamTheme = {
  teamName: string;
  primary: string;
  secondary: string;
  accent: string;
  gradient: string;
  glow: string;
  darkBackground: string;
  border: string;
  ringGradient: string;
};

export const teamThemes: Record<string, TeamTheme> = {
  "Indore Pink Panthers": {
    teamName: "Indore Pink Panthers",
    primary: "#7C3AED",
    secondary: "#A855F7",
    accent: "#22D3EE",
    gradient: "linear-gradient(135deg, rgba(124,58,237,0.95), rgba(34,211,238,0.9))",
    glow: "rgba(124,58,237,0.45)",
    darkBackground: "rgba(15,23,42,0.92)",
    border: "rgba(124,58,237,0.5)",
    ringGradient: "conic-gradient(from 180deg, #7C3AED, #22D3EE, #A855F7, #7C3AED)",
  },
  "Gwalior Cheetahs": {
    teamName: "Gwalior Cheetahs",
    primary: "#EF4444",
    secondary: "#F97316",
    accent: "#FDE047",
    gradient: "linear-gradient(135deg, rgba(239,68,68,0.95), rgba(249,115,22,0.92))",
    glow: "rgba(239,68,68,0.42)",
    darkBackground: "rgba(17,24,39,0.92)",
    border: "rgba(249,115,22,0.55)",
    ringGradient: "conic-gradient(from 180deg, #EF4444, #F97316, #FDE047, #EF4444)",
  },
  "Bundelkhand Bulls": {
    teamName: "Bundelkhand Bulls",
    primary: "#0EA5E9",
    secondary: "#14B8A6",
    accent: "#22C55E",
    gradient: "linear-gradient(135deg, rgba(14,165,233,0.95), rgba(20,184,166,0.92))",
    glow: "rgba(14,165,233,0.40)",
    darkBackground: "rgba(8,15,40,0.92)",
    border: "rgba(20,184,166,0.55)",
    ringGradient: "conic-gradient(from 180deg, #0EA5E9, #14B8A6, #22C55E, #0EA5E9)",
  },
  "Jabalpur Royal Lions": {
    teamName: "Jabalpur Royal Lions",
    primary: "#1D4ED8",
    secondary: "#6366F1",
    accent: "#38BDF8",
    gradient: "linear-gradient(135deg, rgba(29,78,216,0.95), rgba(56,189,248,0.88))",
    glow: "rgba(29,78,216,0.42)",
    darkBackground: "rgba(10,20,40,0.92)",
    border: "rgba(99,102,241,0.55)",
    ringGradient: "conic-gradient(from 180deg, #1D4ED8, #38BDF8, #6366F1, #1D4ED8)",
  },
  "Ujjain Falcons": {
    teamName: "Ujjain Falcons",
    primary: "#8B5CF6",
    secondary: "#C084FC",
    accent: "#F472B6",
    gradient: "linear-gradient(135deg, rgba(139,92,246,0.95), rgba(244,114,182,0.9))",
    glow: "rgba(139,92,246,0.42)",
    darkBackground: "rgba(18,12,38,0.92)",
    border: "rgba(192,132,252,0.55)",
    ringGradient: "conic-gradient(from 180deg, #8B5CF6, #F472B6, #C084FC, #8B5CF6)",
  },
  "Royal Nimar Eagles": {
    teamName: "Royal Nimar Eagles",
    primary: "#F43F5E",
    secondary: "#FB7185",
    accent: "#F97316",
    gradient: "linear-gradient(135deg, rgba(244,63,94,0.95), rgba(249,115,22,0.9))",
    glow: "rgba(244,63,94,0.44)",
    darkBackground: "rgba(26,10,22,0.92)",
    border: "rgba(251,113,133,0.55)",
    ringGradient: "conic-gradient(from 180deg, #F43F5E, #F97316, #FB7185, #F43F5E)",
  },
  "Chambal Ghariyals": {
    teamName: "Chambal Ghariyals",
    primary: "#10B981",
    secondary: "#34D399",
    accent: "#F59E0B",
    gradient: "linear-gradient(135deg, rgba(16,185,129,0.95), rgba(245,158,11,0.9))",
    glow: "rgba(16,185,129,0.4)",
    darkBackground: "rgba(8,24,22,0.92)",
    border: "rgba(52,211,153,0.55)",
    ringGradient: "conic-gradient(from 180deg, #10B981, #F59E0B, #34D399, #10B981)",
  },
  "Rewa Jaguars": {
    teamName: "Rewa Jaguars",
    primary: "#0284C7",
    secondary: "#38BDF8",
    accent: "#60A5FA",
    gradient: "linear-gradient(135deg, rgba(2,132,199,0.95), rgba(96,165,250,0.9))",
    glow: "rgba(2,132,199,0.42)",
    darkBackground: "rgba(8,16,30,0.92)",
    border: "rgba(56,189,248,0.55)",
    ringGradient: "conic-gradient(from 180deg, #0284C7, #60A5FA, #38BDF8, #0284C7)",
  },
  "Bhopal Leopards": {
    teamName: "Bhopal Leopards",
    primary: "#7C2D12",
    secondary: "#EA580C",
    accent: "#F59E0B",
    gradient: "linear-gradient(135deg, rgba(124,45,18,0.95), rgba(234,88,12,0.9))",
    glow: "rgba(234,88,12,0.38)",
    darkBackground: "rgba(25,12,8,0.92)",
    border: "rgba(245,158,11,0.55)",
    ringGradient: "conic-gradient(from 180deg, #7C2D12, #F59E0B, #EA580C, #7C2D12)",
  },
  "Malwa Stallions": {
    teamName: "Malwa Stallions",
    primary: "#0F172A",
    secondary: "#2563EB",
    accent: "#22D3EE",
    gradient: "linear-gradient(135deg, rgba(15,23,42,0.95), rgba(37,99,235,0.9))",
    glow: "rgba(37,99,235,0.42)",
    darkBackground: "rgba(3,7,18,0.92)",
    border: "rgba(34,211,238,0.55)",
    ringGradient: "conic-gradient(from 180deg, #0F172A, #2563EB, #22D3EE, #0F172A)",
  },
};

export const teamThemeNames = Object.keys(teamThemes);

export const getTeamTheme = (teamName?: string | null) => {
  if (!teamName || !teamThemes[teamName]) {
    return teamThemes["Indore Pink Panthers"];
  }
  return teamThemes[teamName];
};
