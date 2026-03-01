// Supabase Edge Function: verify Paystack payment then create order + order_items.
// Set PAYSTACK_SECRET_KEY in Supabase Dashboard → Edge Functions → Secrets.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface CartItem {
  id: string;
  name?: string;
  price: number;
  quantity: number;
  image_url?: string;
}

interface Body {
  reference: string;
  customer_name: string;
  customer_email: string;
  customer_phone: string;
  delivery_address: string;
  delivery_location: string;
  subtotal: number;
  shipping: number;
  total: number;
  cart: CartItem[];
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  try {
    const body = (await req.json()) as Body;
    const { reference, customer_name, customer_email, customer_phone, delivery_address, delivery_location, subtotal, shipping, total, cart } = body;

    if (!reference || !customer_email || !customer_name || !customer_phone || !delivery_address || !Array.isArray(cart) || cart.length === 0) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: reference, customer details, and cart" }),
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
    const expectedKobo = Math.round(Number(total) * 100);
    if (amountPaidKobo !== expectedKobo) {
      return new Response(
        JSON.stringify({ error: "Payment amount does not match order total" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceRoleKey) {
      console.error("SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY missing in Edge Function env");
      return new Response(
        JSON.stringify({ error: "Server misconfiguration. Please contact support." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const { data: existing } = await supabase.from("orders").select("id").eq("paystack_reference", reference).maybeSingle();
    if (existing) {
      return new Response(
        JSON.stringify({ error: "This payment has already been used for an order." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const orderNumber = "CRV-" + new Date().toISOString().slice(0, 10).replace(/-/g, "") + "-" + Array.from(crypto.getRandomValues(new Uint8Array(4))).map((b) => b.toString(16).padStart(2, "0")).join("").toUpperCase().slice(0, 8);

    const { data: orderRow, error: orderErr } = await supabase
      .from("orders")
      .insert({
        order_number: orderNumber,
        customer_email: customer_email.trim(),
        customer_name: customer_name.trim(),
        customer_phone: customer_phone.trim(),
        delivery_address: delivery_address.trim(),
        subtotal: Number(subtotal),
        shipping: Number(shipping),
        total: Number(total),
        status: "paid",
        paystack_reference: reference,
        paystack_status: "success",
      })
      .select("id")
      .single();

    if (orderErr || !orderRow?.id) {
      console.error("Order insert error:", orderErr);
      return new Response(
        JSON.stringify({ error: orderErr?.message || "Order could not be created" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const orderItems = cart.map((item) => ({
      order_id: orderRow.id,
      product_id: item.id || null,
      product_snapshot: { name: item.name || "Product", price: item.price, image_url: item.image_url || "" },
      quantity: Math.max(1, Number(item.quantity) || 1),
      price: Number(item.price),
    }));

    const { error: itemsErr } = await supabase.from("order_items").insert(orderItems);
    if (itemsErr) {
      console.error("Order items insert error:", itemsErr);
      return new Response(
        JSON.stringify({ error: itemsErr.message || "Order items could not be saved" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

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
