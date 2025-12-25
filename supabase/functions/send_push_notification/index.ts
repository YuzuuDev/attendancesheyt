import { serve } from "https://deno.land/std/http/server.ts";

const FCM_SERVER_KEY = Deno.env.get("FCM_SERVER_KEY")!;

serve(async (req) => {
  const { token, title, body } = await req.json();

  const res = await fetch("https://fcm.googleapis.com/fcm/send", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `key=${FCM_SERVER_KEY}`,
    },
    body: JSON.stringify({
      to: token,
      notification: {
        title,
        body,
      },
    }),
  });

  return new Response(JSON.stringify({ success: res.ok }), {
    headers: { "Content-Type": "application/json" },
  });
});
