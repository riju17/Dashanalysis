import { redirect } from "next/navigation";

export default function TournamentIndexPage({ params }: { params: { slug: string } }) {
  redirect(`/tournament/${params.slug}/dashboard`);
}
