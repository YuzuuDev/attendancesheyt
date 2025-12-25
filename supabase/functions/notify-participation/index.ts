import { serve } from "https://deno.land/std/http/server.ts";
import admin from "npm:firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(JSON.parse(
      Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!
    )),
  });
}

serve(async (req) => {
  const { student_id, points, reason } = await req.json();

  const supabase = await import("npm:@supabase/supabase-js");
  const client = supabase.createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { data: tokens } = await client
    .from("device_tokens")
    .select("fcm_token")
    .eq("user_id", student_id);

  if (!tokens || tokens.length === 0) {
    return new Response("No tokens", { status: 200 });
  }

  await admin.messaging().sendEachForMulticast({
    tokens: tokens.map(t => t.fcm_token),
    notification: {
      title: "Participation Points Added",
      body: `+${points} points — ${reason}`,
    },
  });

  return new Response("OK");
});
