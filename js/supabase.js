(function() {
  var config = window.CRYPVILLA_CONFIG;
  if (!config || !config.SUPABASE_URL || !config.SUPABASE_ANON_KEY) {
    console.warn('Crypvilla: SUPABASE_URL and SUPABASE_ANON_KEY must be set in config.js');
    window.supabase = null;
    return;
  }
  var createClient = (typeof supabase !== 'undefined' && supabase.createClient)
    ? supabase.createClient
    : (typeof window.supabase !== 'undefined' && window.supabase.createClient ? window.supabase.createClient : null);
  if (createClient) {
    window.supabase = createClient(config.SUPABASE_URL, config.SUPABASE_ANON_KEY);
  } else {
    window.supabase = null;
  }
})();
