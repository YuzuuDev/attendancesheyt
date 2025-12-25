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
  const { class_id } = await req.json();

  const supabase = await import("npm:@supabase/supabase-js");
  const client = supabase.createClient(
    Deno.env.get("URL")!,
    Deno.env.get("SERVICE_ROLE_KEY")!
  );

  const { data: students } = await client
    .from("class_students")
    .select("student_id")
    .eq("class_id", class_id);

  if (!students) return new Response("No students");

  for (const s of students) {
    const { data: tokens } = await client
      .from("device_tokens")
      .select("fcm_token")
      .eq("user_id", s.student_id);

    if (!tokens) continue;

    await admin.messaging().sendEachForMulticast({
      tokens: tokens.map(t => t.fcm_token),
      notification: {
        title: "Attendance Open",
        body: "Attendance session is now active. Scan the QR.",
      },
    });
  }

  return new Response("OK");
});
