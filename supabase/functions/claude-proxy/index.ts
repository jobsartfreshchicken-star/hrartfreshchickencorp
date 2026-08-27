// Proxies chat requests to Claude (Anthropic) so the browser can call it without
// hitting CORS restrictions on direct browser requests. Each caller supplies their
// own Anthropic API key in the request body; it is forwarded to Anthropic and never stored.
import Anthropic from "npm:@anthropic-ai/sdk";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { model, system, messages, apiKey } = await req.json();

    if (!apiKey || typeof apiKey !== 'string') {
      return new Response(JSON.stringify({ error: { message: 'Missing Anthropic API key.' } }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }
    if (!model || !Array.isArray(messages)) {
      return new Response(JSON.stringify({ error: { message: 'Missing model or messages.' } }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const client = new Anthropic({ apiKey });
    const message = await client.messages.create({
      model,
      max_tokens: 16000,
      system,
      messages,
    });

    return new Response(JSON.stringify(message), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    const status = (e && typeof e.status === 'number') ? e.status : 500;
    const message = (e && e.message) ? e.message : String(e);
    return new Response(JSON.stringify({ error: { message } }), {
      status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
