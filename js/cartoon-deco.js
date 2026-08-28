(function() {
  var IMAGES = [
    'animations/WhatsApp Image 2026-02-26 at 12.04.43 AM (1).jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.43 AM.jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.44 AM.jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.45 AM (1).jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.45 AM.jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.46 AM (1).jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.46 AM.jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.48 AM (1).jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.48 AM (2).jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.48 AM (3).jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.48 AM.jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.49 AM (1).jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.49 AM (2).jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.49 AM (3).jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.49 AM (4).jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.04.49 AM.jpeg',
    'animations/WhatsApp Image 2026-02-26 at 12.08.34 AM.jpeg'
  ];

  var SIZES = ['deco-sm', 'deco-md', 'deco-lg', 'deco-xl'];
  var SECTION_SELECTORS = '.home-section, .closing-band, .hero-editorial, main, .shop-hero, .product-layout';

  function pick(arr) {
    return arr[Math.floor(Math.random() * arr.length)];
  }

  function shuffle(arr) {
    var copy = arr.slice();
    for (var i = copy.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      var tmp = copy[i];
      copy[i] = copy[j];
      copy[j] = tmp;
    }
    return copy;
  }

  function randomEdgePosition() {
    var side = pick(['left', 'right', 'top', 'bottom']);
    var style = {};
    if (side === 'left') {
      style.left = (1 + Math.random() * 7) + '%';
      style.top = (6 + Math.random() * 82) + '%';
    } else if (side === 'right') {
      style.right = (1 + Math.random() * 7) + '%';
      style.top = (6 + Math.random() * 82) + '%';
    } else if (side === 'top') {
      style.top = (2 + Math.random() * 10) + '%';
      style.left = (6 + Math.random() * 82) + '%';
    } else {
      style.bottom = (2 + Math.random() * 12) + '%';
      style.left = (6 + Math.random() * 82) + '%';
    }
    if (Math.random() > 0.45) {
      style.transform = 'rotate(' + (Math.random() * 28 - 14).toFixed(1) + 'deg)';
    }
    return style;
  }

  function randomSectionPosition() {
    var style = {};
    if (Math.random() > 0.5) {
      style.left = (2 + Math.random() * 12) + '%';
    } else {
      style.right = (2 + Math.random() * 12) + '%';
    }
    style.top = (10 + Math.random() * 70) + '%';
    if (Math.random() > 0.6) {
      style.transform = 'rotate(' + (Math.random() * 20 - 10).toFixed(1) + 'deg)';
    }
    return style;
  }

  function createImg(src, sizeClass, style, dark) {
    var img = document.createElement('img');
    img.src = src;
    img.alt = '';
    img.className = sizeClass;
    img.loading = 'lazy';
    img.decoding = 'async';
    Object.keys(style).forEach(function(key) {
      img.style[key] = style[key];
    });
    if (dark) {
      img.style.mixBlendMode = 'lighten';
      img.style.opacity = (0.18 + Math.random() * 0.14).toFixed(2);
    }
    return img;
  }

  function init() {
    if (document.body.classList.contains('page-admin')) return;

    var isMobile = window.innerWidth <= 768;
    var fixedCount = isMobile ? 5 : 9;
    var perSection = isMobile ? 1 : 2;
    var pool = shuffle(IMAGES);
    var poolIndex = 0;

    function nextImage() {
      var src = pool[poolIndex % pool.length];
      poolIndex += 1;
      return src;
    }

    var layer = document.createElement('div');
    layer.className = 'cartoon-deco';
    layer.setAttribute('aria-hidden', 'true');
    for (var i = 0; i < fixedCount; i++) {
      layer.appendChild(createImg(nextImage(), pick(SIZES), randomEdgePosition(), false));
    }
    document.body.insertBefore(layer, document.body.firstChild);

    document.querySelectorAll(SECTION_SELECTORS).forEach(function(section) {
      if (section.closest('.cartoon-deco')) return;
      var isDark = section.classList.contains('closing-band');
      var deco = document.createElement('div');
      deco.className = 'section-cartoon-deco' + (isDark ? ' cartoon-deco-dark' : '');
      for (var j = 0; j < perSection; j++) {
        var size = pick(isMobile ? ['deco-sm', 'deco-md'] : ['deco-sm', 'deco-md', 'deco-lg']);
        deco.appendChild(createImg(nextImage(), size, randomSectionPosition(), isDark));
      }
      section.insertBefore(deco, section.firstChild);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
