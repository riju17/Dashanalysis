import { Suspense } from "react";
import { Loader } from "@/components/ui/Loader";
import PlayersClient from "./PlayersClient";

export default function PlayersPage() {
  return (
    <Suspense fallback={<Loader />}>
      <PlayersClient />
    </Suspense>
  );
}
