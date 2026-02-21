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

  function updateNavBadge() {
    var el = document.getElementById('navCartCount');
    if (el) {
      var n = getCount();
      el.textContent = n;
      el.classList.toggle('d-none', n === 0);
    }
  }

  function dispatchCartUpdate() {
    var count = getCount();
    updateNavBadge();
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

  window.CrypvillaCart = {
    get: getCart,
    getCount: getCount,
    getShipping: getShipping,
    getSubtotal: function() {
      return getCart().reduce(function(sum, item) {
        return sum + (item.price * (item.quantity || 0));
      }, 0);
    },
    add: function(productId, quantity, product) {
      quantity = Math.max(1, parseInt(quantity, 10) || 1);
      var cart = getCart();
      var i = cart.findIndex(function(item) { return item.id === productId; });
      var category_slug = (product && product.category_slug) != null ? product.category_slug : '';
      if (i >= 0) {
        cart[i].quantity += quantity;
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
    onUpdate: function(callback) {
      window.addEventListener('crypvilla:cartUpdate', function(e) { callback(e.detail); });
    }
  };

  dispatchCartUpdate();
})();
