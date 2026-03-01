// Supabase Edge Function: verify Paystack payment then complete offer (create order via RPC).
// Set PAYSTACK_SECRET_KEY in Supabase Dashboard → Edge Functions → Secrets.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Max-Age": "86400",
};

interface Body {
  reference: string;
  expected_amount_kobo: number;
  token: string;
  customer_name: string;
  customer_phone: string;
  delivery_address: string;
  delivery_location: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { status: 200, headers: corsHeaders });
  }

  try {
    const body = (await req.json()) as Body;
    const { reference, expected_amount_kobo, token, customer_name, customer_phone, delivery_address, delivery_location } = body;

    if (!reference || expected_amount_kobo == null || !token || !customer_name || !customer_phone || !delivery_address) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: reference, expected_amount_kobo, token, customer details" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const secret = Deno.env.get("PAYSTACK_SECRET_KEY");
    if (!secret) {
      console.error("PAYSTACK_SECRET_KEY not set");
      return new Response(
        JSON.stringify({ error: "Payment verification not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const verifyRes = await fetch(`https://api.paystack.co/transaction/verify/${encodeURIComponent(reference)}`, {
      headers: { Authorization: `Bearer ${secret}` },
    });
    const verifyData = await verifyRes.json();

    if (!verifyData.status || verifyData.data?.status !== "success") {
      return new Response(
        JSON.stringify({ error: "Payment verification failed or transaction not successful" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const amountPaidKobo = Number(verifyData.data?.amount) || 0;
    if (amountPaidKobo !== Number(expected_amount_kobo)) {
      return new Response(
        JSON.stringify({ error: "Payment amount does not match offer total" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const { data: existing } = await supabase.from("orders").select("id").eq("paystack_reference", reference).maybeSingle();
    if (existing) {
      return new Response(
        JSON.stringify({ error: "This payment has already been used for an order." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { data: rpcData, error: rpcErr } = await supabase.rpc("complete_offer_payment", {
      p_token: token.trim(),
      p_paystack_reference: reference,
      p_customer_name: customer_name.trim(),
      p_customer_phone: customer_phone.trim(),
      p_delivery_address: delivery_address.trim(),
      p_delivery_location: (delivery_location || "lagos").trim(),
    });

    if (rpcErr) {
      return new Response(
        JSON.stringify({ error: rpcErr.message || "Offer completion failed" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const result = typeof rpcData === "string" ? (() => { try { return JSON.parse(rpcData); } catch { return null; } })() : rpcData;
    const orderNumber = result?.order_number || reference;

    return new Response(
      JSON.stringify({ order_number: orderNumber }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    console.error(e);
    return new Response(
      JSON.stringify({ error: e instanceof Error ? e.message : "Server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
