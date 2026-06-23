import { redirect } from "next/navigation";

export default function TournamentMatchesPage({ params }: { params: { slug: string } }) {
  redirect(`/tournament/${params.slug}/data-manager`);
}
