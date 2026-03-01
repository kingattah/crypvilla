/**
 * Escape HTML to prevent XSS when inserting untrusted data into innerHTML or attributes.
 * Use for product names, category names, customer input, and any data from DB or user.
 */
(function() {
  function escapeHtml(s) {
    if (s == null || s === undefined) return '';
    var str = String(s);
    return str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  /**
   * Return URL safe for img src or a href. Blocks javascript: and data: (except safe image data URIs if needed).
   * Returns empty string for invalid URLs so we can fall back to placeholder.
   */
  function safeUrl(url) {
    if (url == null || url === undefined) return '';
    var u = String(url).trim();
    if (u === '') return '';
    var lower = u.toLowerCase();
    if (lower.indexOf('javascript:') === 0 || lower.indexOf('data:') === 0) return '';
    if (lower.indexOf('http://') !== 0 && lower.indexOf('https://') !== 0 && u.indexOf('/') !== 0) return '';
    return u;
  }

  window.CrypvillaEscape = {
    html: escapeHtml,
    url: safeUrl
  };
})();
