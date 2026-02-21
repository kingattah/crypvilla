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

  window.CrypvillaCart = {
    get: getCart,
    getCount: getCount,
    add: function(productId, quantity, product) {
      quantity = Math.max(1, parseInt(quantity, 10) || 1);
      var cart = getCart();
      var i = cart.findIndex(function(item) { return item.id === productId; });
      if (i >= 0) {
        cart[i].quantity += quantity;
      } else {
        cart.push({
          id: productId,
          quantity: quantity,
          name: (product && product.name) || '',
          price: (product && product.price) != null ? Number(product.price) : 0,
          image_url: (product && product.image_url) || ''
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
    getSubtotal: function() {
      return getCart().reduce(function(sum, item) {
        return sum + (item.price * (item.quantity || 0));
      }, 0);
    },
    onUpdate: function(callback) {
      window.addEventListener('crypvilla:cartUpdate', function(e) { callback(e.detail); });
    }
  };

  dispatchCartUpdate();
})();
