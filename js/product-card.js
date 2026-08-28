(function() {
  var PLACEHOLDER = 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800&q=80';

  function escHtml(s) {
    var esc = window.CrypvillaEscape;
    if (esc && esc.html) return esc.html(s == null ? '' : s);
    return String(s == null ? '' : s);
  }

  function safeImg(url) {
    var esc = window.CrypvillaEscape;
    if (esc && esc.url) return esc.url(url) || PLACEHOLDER;
    return url || PLACEHOLDER;
  }

  function specDisplayValues(specs, max) {
    max = max || 3;
    specs = specs || {};
    var laptop = [specs.processor, specs.ram, specs.storage].filter(Boolean);
    if (laptop.length) return laptop.slice(0, max);
    var out = [];
    if (specs.label) {
      out.push(String(specs.label));
      if (specs.voltage != null && specs.voltage !== '') out.push(Number(specs.voltage) + 'V');
      if (specs.cable_mm2 != null && specs.cable_mm2 !== '') out.push(Number(specs.cable_mm2) + ' mm²');
      return out.slice(0, max);
    }
    if (specs.watts != null && specs.watts !== '') out.push(Number(specs.watts) + 'W');
    if (specs.kva != null && specs.kva !== '') out.push(Number(specs.kva) + ' kVA');
    if (specs.capacity_wh != null && specs.capacity_wh !== '') {
      var wh = Number(specs.capacity_wh);
      if (!isNaN(wh)) out.push(wh >= 1000 ? (Math.round(wh / 100) / 10) + ' kWh' : wh + ' Wh');
    }
    if (specs.voltage != null && specs.voltage !== '') out.push(Number(specs.voltage) + 'V');
    if (specs.cable_mm2 != null && specs.cable_mm2 !== '') out.push(Number(specs.cable_mm2) + ' mm²');
    if (!out.length) {
      Object.keys(specs).forEach(function(k) {
        if (k === 'kind' || specs[k] == null || specs[k] === '') return;
        out.push(String(specs[k]));
      });
    }
    return out.slice(0, max);
  }

  function categorySlug(p) {
    var cat = p.categories;
    if (!cat) return p.category_slug || '';
    if (Array.isArray(cat)) return (cat[0] && cat[0].slug) || '';
    return cat.slug || '';
  }

  function render(p, options) {
    options = options || {};
    var colClass = options.colClass || 'col-6 col-md-4';
    var specs = p.specs || {};
    var pills = specDisplayValues(specs, 3);
    var stock = parseInt(p.stock, 10);
    if (isNaN(stock) || stock < 0) stock = 999;
    var inStock = stock > 0;
    var priceHtml = p.compare_at_price
      ? '<span class="price-current">₦' + Number(p.price).toLocaleString() + '</span> <span class="price-compare">₦' + Number(p.compare_at_price).toLocaleString() + '</span>'
      : '<span class="price-current">₦' + Number(p.price).toLocaleString() + '</span>';
    var saleBadge = '';
    if (!inStock) saleBadge = '<span class="badge-out-of-stock">Out of stock</span>';
    else if (p.compare_at_price) saleBadge = '<span class="badge-sale">Sale</span>';
    var catSlug = categorySlug(p);
    var laptopSlugs = (window.CRYPVILLA_CONFIG && window.CRYPVILLA_CONFIG.LAPTOP_CATEGORY_SLUGS) || ['grade-a-uk-used-laptops', 'brand-new-laptops'];
    var isLaptop = laptopSlugs.indexOf(catSlug) >= 0;
    var imgUrl = safeImg(p.image_url);
    var name = (p.name || '').substring(0, 60) + ((p.name && p.name.length > 60) ? '…' : '');
    var nameSafe = escHtml(name);
    var pillsSafe = pills.map(function(s) { return '<span class="spec-pill">' + escHtml(s) + '</span>'; }).join('');
    var stockHint = inStock && stock <= 5 ? '<p class="text-warning small mb-1">Only ' + stock + ' left</p>' : '';
    var nameAttr = escHtml(p.name || '');
    var imgAttr = escHtml(p.image_url || '');
    var href = (window.CrypvillaPaths && window.CrypvillaPaths.product)
      ? window.CrypvillaPaths.product(p)
      : ('product?id=' + encodeURIComponent(p.id));
    var addBtn = inStock
      ? '<button type="button" class="btn btn-sm btn-shop add-to-cart" data-id="' + escHtml(p.id) + '" data-name="' + nameAttr + '" data-price="' + p.price + '" data-image="' + imgAttr + '" data-category="' + escHtml(catSlug) + '" data-stock="' + stock + '">Add to bag</button>'
      : '<button type="button" class="btn btn-sm btn-outline-secondary" disabled>Out of stock</button>';

    var card = document.createElement('div');
    card.className = colClass;
    card.innerHTML =
      '<div class="card card-product h-100' + (inStock ? '' : ' card-out-of-stock') + '">' +
        '<div class="img-wrap">' + saleBadge +
          '<a href="' + href + '"><img src="' + imgUrl.replace(/"/g, '&quot;') + '" alt="' + nameSafe + '" loading="lazy"></a>' +
        '</div>' +
        '<div class="card-body">' +
          '<h3 class="card-title"><a href="' + href + '">' + nameSafe + '</a></h3>' +
          '<p class="mb-1">' + priceHtml + '</p>' +
          stockHint +
          (isLaptop ? '<p class="laptop-bag-note mb-1">Includes laptop bag</p>' : '') +
          (pills.length ? '<div class="spec-pills">' + pillsSafe + '</div>' : '') +
          '<div class="card-actions d-flex gap-2">' +
            '<a href="' + href + '" class="btn btn-sm btn-outline-secondary flex-grow-1">View</a>' +
            addBtn +
          '</div>' +
        '</div>' +
      '</div>';
    return card;
  }

  function skeleton(count, colClass) {
    count = count || 6;
    colClass = colClass || 'col-6 col-md-4';
    var wrap = document.createDocumentFragment();
    for (var i = 0; i < count; i++) {
      var el = document.createElement('div');
      el.className = colClass;
      el.innerHTML = '<div class="skeleton-card"><div class="skeleton-img"></div><div class="skeleton-line"></div><div class="skeleton-line short"></div></div>';
      wrap.appendChild(el);
    }
    return wrap;
  }

  function bindAddToCart() {
    if (document.documentElement.dataset.cvCardBound) return;
    document.documentElement.dataset.cvCardBound = '1';
    document.addEventListener('click', function(e) {
      var btn = e.target.closest('.add-to-cart');
      if (!btn || btn.disabled) return;
      e.preventDefault();
      var id = btn.getAttribute('data-id');
      var name = btn.getAttribute('data-name') || '';
      var price = btn.getAttribute('data-price');
      var image = btn.getAttribute('data-image') || '';
      var category = btn.getAttribute('data-category') || '';
      var stock = parseInt(btn.getAttribute('data-stock'), 10) || 999;
      if (!id || !window.CrypvillaCart) return;
      if (stock < 1) return;
      window.CrypvillaCart.add(id, 1, { name: name, price: price, image_url: image, category_slug: category }, stock);
      var t = btn.textContent;
      btn.textContent = 'Added';
      btn.disabled = true;
      setTimeout(function() { btn.textContent = t; btn.disabled = false; }, 1400);
    });
  }

  bindAddToCart();

  window.CrypvillaProductCard = {
    specDisplayValues: specDisplayValues,
    render: render,
    skeleton: skeleton
  };
})();
