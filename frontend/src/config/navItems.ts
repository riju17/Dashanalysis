import {
  Activity,
  Shield,
  LineChart,
  Users,
  Trophy,
  Database,
  Settings2,
  FileText,
  MapPin,
  Target,
  LayoutDashboard,
  PlusCircle,
} from "lucide-react";

import { buildTournamentPath } from "@/lib/tournament";

export function getNavItems(slug?: string | null) {
  if (!slug) {
    return [
      { label: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
      { label: "Match Entry", href: "/add-match", icon: PlusCircle },
      { label: "Team Analysis", href: "/teams", icon: Activity },
      { label: "Player Analysis", href: "/players", icon: Users },
      { label: "Venue Analysis", href: "/venues", icon: MapPin },
      { label: "Toss Analysis", href: "/toss", icon: Target },
      { label: "Opponent Strategy", href: "/opponent-strategy", icon: Shield },
      { label: "Prediction", href: "/prediction", icon: LineChart },
      { label: "Tournament", href: "/tournament", icon: Trophy },
      { label: "Data Manager", href: "/data-manager", icon: Database },
      { label: "Admin", href: "/admin", icon: Settings2 },
      { label: "Reports", href: "/reports", icon: FileText },
    ];
  }

  return [
    { label: "Dashboard", href: buildTournamentPath(slug, "/dashboard"), icon: LayoutDashboard },
    { label: "Match Entry", href: buildTournamentPath(slug, "/add-match"), icon: PlusCircle },
    { label: "Team Analysis", href: buildTournamentPath(slug, "/teams"), icon: Activity },
    { label: "Player Analysis", href: buildTournamentPath(slug, "/players"), icon: Users },
    { label: "Venue Analysis", href: buildTournamentPath(slug, "/venues"), icon: MapPin },
    { label: "Toss Analysis", href: buildTournamentPath(slug, "/toss"), icon: Target },
    { label: "Opponent Strategy", href: buildTournamentPath(slug, "/opponent-strategy"), icon: Shield },
    { label: "Prediction", href: buildTournamentPath(slug, "/prediction"), icon: LineChart },
    { label: "Tournament", href: buildTournamentPath(slug, "/tournament"), icon: Trophy },
    { label: "Data Manager", href: buildTournamentPath(slug, "/data-manager"), icon: Database },
    { label: "Admin", href: buildTournamentPath(slug, "/admin"), icon: Settings2 },
    { label: "Reports", href: buildTournamentPath(slug, "/reports"), icon: FileText },
  ];
}
