(function() {
  var STORAGE_KEY = 'crypvilla_cart';

  function getCart() {
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch (e) {
      return [];
    }
  }

  function getCount() {
    return getCart().reduce(function(sum, item) { return sum + (item.quantity || 0); }, 0);
  }

  function setCart(items) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
    dispatchCartUpdate();
  }

  function formatNaira(n) {
    return '₦' + (Number(n) || 0).toLocaleString();
  }

  function isQuietPage() {
    var path = (window.location.pathname || '').toLowerCase();
    return /cart\.html$/.test(path) || /checkout\.html$/.test(path);
  }

  function updateNavBadge() {
    var n = getCount();
    ['navCartCount', 'navCartCountMobile'].forEach(function(id) {
      var el = document.getElementById(id);
      if (el) {
        el.textContent = n;
        el.classList.toggle('d-none', n === 0);
      }
    });
  }

  function dispatchCartUpdate() {
    var count = getCount();
    updateNavBadge();
    renderMiniCart();
    window.dispatchEvent(new CustomEvent('crypvilla:cartUpdate', { detail: { count: count } }));
  }

  function getShipping(cart, isLagos) {
    var config = window.CRYPVILLA_CONFIG || {};
    var threshold = config.FREE_SHIPPING_THRESHOLD || 500000;
    var freeLaptopCount = config.FREE_LAPTOP_COUNT || 4;
    var laptopSlugs = config.LAPTOP_CATEGORY_SLUGS || ['grade-a-uk-used-laptops', 'brand-new-laptops'];
    var lagosAcc = config.SHIPPING_LAGOS_ACCESSORIES != null ? config.SHIPPING_LAGOS_ACCESSORIES : 5000;
    var outsideAcc = config.SHIPPING_OUTSIDE_ACCESSORIES != null ? config.SHIPPING_OUTSIDE_ACCESSORIES : 8000;
    var lagosLaptop = config.SHIPPING_LAGOS_LAPTOP != null ? config.SHIPPING_LAGOS_LAPTOP : 8000;
    var outsideLaptop = config.SHIPPING_OUTSIDE_LAPTOP != null ? config.SHIPPING_OUTSIDE_LAPTOP : 22000;

    var subtotal = cart.reduce(function(s, i) { return s + (i.price || 0) * (i.quantity || 1); }, 0);
    var laptopUnits = 0;
    var hasLaptop = false;
    (cart || []).forEach(function(item) {
      var slug = (item.category_slug || '').toLowerCase();
      var qty = item.quantity || 1;
      if (laptopSlugs.indexOf(slug) >= 0) {
        laptopUnits += qty;
        hasLaptop = true;
      }
    });

    if (laptopUnits >= freeLaptopCount) return { fee: 0, hint: 'Free delivery (4+ laptops).' };
    if (isLagos && subtotal >= threshold) return { fee: 0, hint: 'Free delivery in Lagos (order over ₦' + (threshold / 1e5).toFixed(0) + '0k).' };

    var fee = hasLaptop ? (isLagos ? lagosLaptop : outsideLaptop) : (isLagos ? lagosAcc : outsideAcc);
    var hint = isLagos ? 'Lagos delivery.' : 'Outside Lagos delivery.';
    return { fee: fee, hint: hint };
  }

  function escHtml(s) {
    var esc = window.CrypvillaEscape;
    if (esc && esc.html) return esc.html(s == null ? '' : s);
    return String(s == null ? '' : s);
  }

  function safeImg(url) {
    var esc = window.CrypvillaEscape;
    if (esc && esc.url) return esc.url(url) || 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=200&q=80';
    return url || 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=200&q=80';
  }

  function ensureToast() {
    if (document.getElementById('cvToastStack')) return;
    var stack = document.createElement('div');
    stack.id = 'cvToastStack';
    stack.className = 'toast-stack';
    stack.setAttribute('aria-live', 'polite');
    document.body.appendChild(stack);
  }

  function showToast(message, type) {
    ensureToast();
    var stack = document.getElementById('cvToastStack');
    var el = document.createElement('div');
    el.className = 'cv-toast' + (type === 'error' ? ' is-error' : '');
    el.textContent = message;
    stack.appendChild(el);
    setTimeout(function() {
      if (el.parentNode) el.parentNode.removeChild(el);
    }, 3200);
  }

  function ensureMiniCart() {
    if (document.getElementById('miniCartDrawer')) return;
    var html =
      '<div class="mini-cart-backdrop" id="miniCartBackdrop" aria-hidden="true"></div>' +
      '<aside class="mini-cart" id="miniCartDrawer" role="dialog" aria-modal="true" aria-labelledby="miniCartTitle" aria-hidden="true">' +
        '<div class="mini-cart-header">' +
          '<h2 id="miniCartTitle">Your bag</h2>' +
          '<button type="button" class="mini-cart-close" id="miniCartClose" aria-label="Close bag">&times;</button>' +
        '</div>' +
        '<div class="mini-cart-body" id="miniCartBody"></div>' +
        '<div class="mini-cart-footer" id="miniCartFooter"></div>' +
      '</aside>';
    document.body.insertAdjacentHTML('beforeend', html);
    document.getElementById('miniCartBackdrop').addEventListener('click', closeMiniCart);
    document.getElementById('miniCartClose').addEventListener('click', closeMiniCart);
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') {
        var drawer = document.getElementById('miniCartDrawer');
        if (drawer && drawer.classList.contains('is-open')) closeMiniCart();
      }
    });
    document.body.addEventListener('click', function(e) {
      var trigger = e.target.closest('[data-open-cart]');
      if (!trigger) return;
      e.preventDefault();
      openMiniCart();
    });
  }

  function renderMiniCart() {
    var body = document.getElementById('miniCartBody');
    var footer = document.getElementById('miniCartFooter');
    if (!body || !footer) return;
    var cart = getCart();
    if (!cart.length) {
      body.innerHTML = '<div class="mini-cart-empty"><p>Your bag is empty.</p><a href="shop.html" class="btn-text">Continue shopping</a></div>';
      footer.innerHTML = '';
      return;
    }
    body.innerHTML = cart.map(function(item) {
      var qty = item.quantity || 1;
      return '<div class="mini-cart-line">' +
        '<img src="' + safeImg(item.image_url).replace(/"/g, '&quot;') + '" alt="">' +
        '<div>' +
          '<a href="' + ((window.CrypvillaPaths && window.CrypvillaPaths.product)
            ? window.CrypvillaPaths.product({ id: item.id })
            : ('product?id=' + encodeURIComponent(item.id))) + '" class="cart-line-name">' + escHtml((item.name || 'Product').substring(0, 48)) + '</a>' +
          '<p class="cart-line-meta mb-0">' + qty + ' × ' + formatNaira(item.price) + '</p>' +
        '</div>' +
        '<span>' + formatNaira((item.price || 0) * qty) + '</span>' +
      '</div>';
    }).join('');
    var subtotal = cart.reduce(function(sum, item) {
      return sum + (item.price * (item.quantity || 0));
    }, 0);
    footer.innerHTML =
      '<p class="d-flex justify-content-between mb-2"><span class="text-muted">Subtotal</span><strong>' + formatNaira(subtotal) + '</strong></p>' +
      '<a href="cart.html" class="btn btn-outline-secondary">View bag</a>' +
      '<a href="checkout.html" class="btn btn-shop">Checkout</a>';
  }

  function openMiniCart() {
    ensureMiniCart();
    renderMiniCart();
    var drawer = document.getElementById('miniCartDrawer');
    var backdrop = document.getElementById('miniCartBackdrop');
    drawer.setAttribute('aria-hidden', 'false');
    backdrop.setAttribute('aria-hidden', 'false');
    requestAnimationFrame(function() {
      drawer.classList.add('is-open');
      backdrop.classList.add('is-open');
      var closeBtn = document.getElementById('miniCartClose');
      if (closeBtn) closeBtn.focus();
    });
    document.body.classList.add('mini-cart-open');
  }

  function closeMiniCart() {
    var drawer = document.getElementById('miniCartDrawer');
    var backdrop = document.getElementById('miniCartBackdrop');
    if (!drawer) return;
    drawer.classList.remove('is-open');
    drawer.setAttribute('aria-hidden', 'true');
    if (backdrop) {
      backdrop.classList.remove('is-open');
      backdrop.setAttribute('aria-hidden', 'true');
    }
    document.body.classList.remove('mini-cart-open');
  }

  window.CrypvillaToast = {
    show: showToast
  };

  window.CrypvillaCart = {
    get: getCart,
    getCount: getCount,
    getShipping: getShipping,
    getSubtotal: function() {
      return getCart().reduce(function(sum, item) {
        return sum + (item.price * (item.quantity || 0));
      }, 0);
    },
    add: function(productId, quantity, product, maxQuantity) {
      quantity = Math.max(1, parseInt(quantity, 10) || 1);
      var cap = maxQuantity != null && maxQuantity !== '' ? Math.max(0, parseInt(maxQuantity, 10)) : null;
      if (cap !== null && quantity > cap) quantity = cap;
      if (cap !== null && quantity <= 0) return getCart();
      var cart = getCart();
      var i = cart.findIndex(function(item) { return item.id === productId; });
      var category_slug = (product && product.category_slug) != null ? product.category_slug : '';
      if (i >= 0) {
        var newQty = cart[i].quantity + quantity;
        if (cap !== null) newQty = Math.min(newQty, cap);
        cart[i].quantity = newQty;
        if (category_slug && !cart[i].category_slug) cart[i].category_slug = category_slug;
      } else {
        cart.push({
          id: productId,
          quantity: quantity,
          name: (product && product.name) || '',
          price: (product && product.price) != null ? Number(product.price) : 0,
          image_url: (product && product.image_url) || '',
          category_slug: category_slug
        });
      }
      setCart(cart);
      if (!isQuietPage() && !(product && product.silent)) openMiniCart();
      return getCart();
    },
    update: function(productId, quantity) {
      quantity = Math.max(0, parseInt(quantity, 10) || 0);
      var cart = getCart();
      if (quantity === 0) {
        cart = cart.filter(function(item) { return item.id !== productId; });
      } else {
        var i = cart.findIndex(function(item) { return item.id === productId; });
        if (i >= 0) cart[i].quantity = quantity;
      }
      setCart(cart);
      return getCart();
    },
    remove: function(productId) {
      return this.update(productId, 0);
    },
    clear: function() {
      setCart([]);
    },
    openDrawer: openMiniCart,
    closeDrawer: closeMiniCart,
    onUpdate: function(callback) {
      window.addEventListener('crypvilla:cartUpdate', function(e) { callback(e.detail); });
    }
  };

  function enhanceNavCart() {
    if (isQuietPage()) return;
    document.querySelectorAll('.nav-cart-mobile, .nav-cart-desktop a, a.nav-cart-link').forEach(function(el) {
      if (el.getAttribute('data-open-cart') != null) return;
      el.setAttribute('data-open-cart', '');
      el.setAttribute('href', 'cart.html');
    });
  }

  function initUi() {
    ensureToast();
    ensureMiniCart();
    enhanceNavCart();
    updateNavBadge();
    renderMiniCart();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initUi);
  } else {
    initUi();
  }

  dispatchCartUpdate();
})();
