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
    primary: "#FF2DAA",
    secondary: "#FFFFFF",
    accent: "#F9A8D4",
    gradient: "linear-gradient(135deg, rgba(255,45,170,0.95), rgba(255,255,255,0.88))",
    glow: "rgba(255,45,170,0.45)",
    darkBackground: "rgba(15,23,42,0.92)",
    border: "rgba(249,168,212,0.55)",
    ringGradient: "conic-gradient(from 180deg, #FF2DAA, #FFFFFF, #F9A8D4, #FF2DAA)",
  },
  "Gwalior Cheetahs": {
    teamName: "Gwalior Cheetahs",
    primary: "#1E3A8A",
    secondary: "#F97316",
    accent: "#FDBA74",
    gradient: "linear-gradient(135deg, rgba(30,58,138,0.95), rgba(249,115,22,0.92))",
    glow: "rgba(30,58,138,0.42)",
    darkBackground: "rgba(10,16,36,0.92)",
    border: "rgba(249,115,22,0.55)",
    ringGradient: "conic-gradient(from 180deg, #1E3A8A, #F97316, #FDBA74, #1E3A8A)",
  },
  "Bundelkhand Bulls": {
    teamName: "Bundelkhand Bulls",
    primary: "#2563EB",
    secondary: "#D4AF37",
    accent: "#93C5FD",
    gradient: "linear-gradient(135deg, rgba(37,99,235,0.95), rgba(212,175,55,0.9))",
    glow: "rgba(37,99,235,0.40)",
    darkBackground: "rgba(8,15,40,0.92)",
    border: "rgba(212,175,55,0.55)",
    ringGradient: "conic-gradient(from 180deg, #2563EB, #D4AF37, #93C5FD, #2563EB)",
  },
  "Jabalpur Royal Lions": {
    teamName: "Jabalpur Royal Lions",
    primary: "#DC2626",
    secondary: "#D4AF37",
    accent: "#FCA5A5",
    gradient: "linear-gradient(135deg, rgba(220,38,38,0.95), rgba(212,175,55,0.9))",
    glow: "rgba(220,38,38,0.42)",
    darkBackground: "rgba(30,10,10,0.92)",
    border: "rgba(212,175,55,0.55)",
    ringGradient: "conic-gradient(from 180deg, #DC2626, #D4AF37, #FCA5A5, #DC2626)",
  },
  "Ujjain Falcons": {
    teamName: "Ujjain Falcons",
    primary: "#EAB308",
    secondary: "#4F46E5",
    accent: "#FDE68A",
    gradient: "linear-gradient(135deg, rgba(234,179,8,0.95), rgba(79,70,229,0.9))",
    glow: "rgba(234,179,8,0.42)",
    darkBackground: "rgba(30,24,8,0.92)",
    border: "rgba(79,70,229,0.55)",
    ringGradient: "conic-gradient(from 180deg, #EAB308, #4F46E5, #FDE68A, #EAB308)",
  },
  "Royal Nimar Eagles": {
    teamName: "Royal Nimar Eagles",
    primary: "#7E22CE",
    secondary: "#D4AF37",
    accent: "#C084FC",
    gradient: "linear-gradient(135deg, rgba(126,34,206,0.95), rgba(212,175,55,0.9))",
    glow: "rgba(126,34,206,0.44)",
    darkBackground: "rgba(24,10,34,0.92)",
    border: "rgba(212,175,55,0.55)",
    ringGradient: "conic-gradient(from 180deg, #7E22CE, #D4AF37, #C084FC, #7E22CE)",
  },
  "Chambal Ghariyals": {
    teamName: "Chambal Ghariyals",
    primary: "#14532D",
    secondary: "#86EFAC",
    accent: "#22C55E",
    gradient: "linear-gradient(135deg, rgba(20,83,45,0.95), rgba(134,239,172,0.9))",
    glow: "rgba(20,83,45,0.4)",
    darkBackground: "rgba(8,24,22,0.92)",
    border: "rgba(134,239,172,0.55)",
    ringGradient: "conic-gradient(from 180deg, #14532D, #86EFAC, #22C55E, #14532D)",
  },
  "Rewa Jaguars": {
    teamName: "Rewa Jaguars",
    primary: "#F97316",
    secondary: "#111111",
    accent: "#FDBA74",
    gradient: "linear-gradient(135deg, rgba(249,115,22,0.95), rgba(17,17,17,0.9))",
    glow: "rgba(249,115,22,0.42)",
    darkBackground: "rgba(8,16,30,0.92)",
    border: "rgba(255,255,255,0.22)",
    ringGradient: "conic-gradient(from 180deg, #F97316, #111111, #FDBA74, #F97316)",
  },
  "Bhopal Leopards": {
    teamName: "Bhopal Leopards",
    primary: "#EAB308",
    secondary: "#7C3AED",
    accent: "#FEF08A",
    gradient: "linear-gradient(135deg, rgba(234,179,8,0.95), rgba(124,58,237,0.9))",
    glow: "rgba(234,179,8,0.42)",
    darkBackground: "rgba(25,12,8,0.92)",
    border: "rgba(124,58,237,0.55)",
    ringGradient: "conic-gradient(from 180deg, #EAB308, #7C3AED, #FEF08A, #EAB308)",
  },
  "Malwa Stallions": {
    teamName: "Malwa Stallions",
    primary: "#2563EB",
    secondary: "#D4AF37",
    accent: "#93C5FD",
    gradient: "linear-gradient(135deg, rgba(37,99,235,0.95), rgba(212,175,55,0.9))",
    glow: "rgba(37,99,235,0.42)",
    darkBackground: "rgba(3,7,18,0.92)",
    border: "rgba(212,175,55,0.55)",
    ringGradient: "conic-gradient(from 180deg, #2563EB, #D4AF37, #93C5FD, #2563EB)",
  },
};

export const teamThemeNames = Object.keys(teamThemes);

export const getTeamTheme = (teamName?: string | null) => {
  if (!teamName || !teamThemes[teamName]) {
    return teamThemes["Indore Pink Panthers"];
  }
  return teamThemes[teamName];
};
