(function() {
  function queryString(params) {
    if (!params) return '';
    var parts = [];
    Object.keys(params).forEach(function(key) {
      var value = params[key];
      if (value == null || value === '') return;
      parts.push(encodeURIComponent(key) + '=' + encodeURIComponent(value));
    });
    return parts.length ? '?' + parts.join('&') : '';
  }

  window.CrypvillaPaths = {
    product: function(product) {
      if (!product) return 'shop.html';
      if (product.id) return 'product' + queryString({ id: product.id });
      if (product.slug) return 'product' + queryString({ slug: product.slug });
      return 'shop.html';
    },
    shop: function(opts) {
      opts = opts || {};
      var params = {};
      if (opts.category) params.category = opts.category;
      if (opts.viewAll) params.view = 'all';
      if (opts.search) params.q = opts.search;
      if (opts.sort && opts.sort !== 'newest') params.sort = opts.sort;
      if (opts.page > 1) params.page = String(opts.page);
      return 'shop' + queryString(params);
    },
    checkout: function(params) {
      return 'checkout' + queryString(params || {});
    }
  };
})();
