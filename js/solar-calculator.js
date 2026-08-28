(function() {
  var PRESETS = [
    { name: 'LED bulb', watts: 10 },
    { name: 'Ceiling fan', watts: 75 },
    { name: 'Standing fan', watts: 60 },
    { name: 'TV 32"', watts: 60 },
    { name: 'TV 55"', watts: 120 },
    { name: 'Fridge', watts: 150 },
    { name: 'Freezer', watts: 200 },
    { name: 'Decoder', watts: 25 },
    { name: 'Laptop', watts: 65 },
    { name: 'Phone charger', watts: 15 },
    { name: 'WiFi router', watts: 12 },
    { name: 'Pumping machine', watts: 750 },
    { name: '1HP AC', watts: 900 },
    { name: '1.5HP AC', watts: 1300 },
    { name: 'Blender', watts: 400 },
    { name: 'Electric iron', watts: 1000 },
    { name: 'Custom', watts: 100 }
  ];
  var INVERTER_STEPS = [1.5, 2.5, 3.5, 5, 7.5, 10];
  var PEAK_SUN_HOURS = 4.5;
  var SYSTEM_EFF = 0.75;
  var DOD = 0.8;
  var WHATSAPP = '2347120043892';

  var rows = [];
  var nextId = 1;
  var solarProducts = [];
  var lastSizes = null;
  var lastKit = null;

  var esc = window.CrypvillaEscape;
  var safeHtml = esc && esc.html ? function(s) { return esc.html(s == null ? '' : s); } : function(s) { return String(s == null ? '' : s); };

  function updateCartCount() {
    var n = window.CrypvillaCart ? window.CrypvillaCart.getCount() : 0;
    ['navCartCount', 'navCartCountMobile'].forEach(function(id) {
      var el = document.getElementById(id);
      if (el) { el.textContent = n; el.classList.toggle('d-none', n === 0); }
    });
  }

  function defaultRows() {
    return [
      { id: nextId++, name: 'LED bulb', watts: 10, qty: 8, hours: 6 },
      { id: nextId++, name: 'Ceiling fan', watts: 75, qty: 3, hours: 8 },
      { id: nextId++, name: 'TV 32"', watts: 60, qty: 1, hours: 6 },
      { id: nextId++, name: 'Fridge', watts: 150, qty: 1, hours: 24 },
      { id: nextId++, name: 'Decoder', watts: 25, qty: 1, hours: 8 }
    ];
  }

  function presetOptions(selected) {
    return PRESETS.map(function(p) {
      var sel = p.name === selected ? ' selected' : '';
      return '<option value="' + safeHtml(p.name) + '"' + sel + '>' + safeHtml(p.name) + '</option>';
    }).join('');
  }

  function wattsForName(name) {
    var p = PRESETS.filter(function(x) { return x.name === name; })[0];
    return p ? p.watts : 100;
  }

  function readRowsFromDom() {
    var tbody = document.getElementById('solarLoadRows');
    if (!tbody) return;
    Array.prototype.forEach.call(tbody.querySelectorAll('tr'), function(tr) {
      var id = parseInt(tr.getAttribute('data-id'), 10);
      var row = rows.filter(function(r) { return r.id === id; })[0];
      if (!row) return;
      var nameEl = tr.querySelector('.load-name');
      var qtyEl = tr.querySelector('.load-qty');
      var wattsEl = tr.querySelector('.load-watts');
      var hoursEl = tr.querySelector('.load-hours');
      if (nameEl) row.name = nameEl.value;
      if (qtyEl) row.qty = Math.max(1, parseInt(qtyEl.value, 10) || 1);
      if (wattsEl) row.watts = Math.max(0, parseFloat(wattsEl.value) || 0);
      if (hoursEl) row.hours = Math.max(0, parseFloat(hoursEl.value) || 0);
    });
  }

  function renderRows() {
    var tbody = document.getElementById('solarLoadRows');
    if (!tbody) return;
    tbody.innerHTML = rows.map(function(r) {
      return '<tr data-id="' + r.id + '">' +
        '<td><select class="form-select form-select-sm load-name">' + presetOptions(r.name) + '</select></td>' +
        '<td><input type="number" class="form-control form-control-sm text-center load-qty" min="1" step="1" value="' + r.qty + '"></td>' +
        '<td><input type="number" class="form-control form-control-sm text-center load-watts" min="0" step="1" value="' + r.watts + '"></td>' +
        '<td><input type="number" class="form-control form-control-sm text-center load-hours" min="0" max="24" step="0.5" value="' + r.hours + '"></td>' +
        '<td class="text-end"><button type="button" class="btn btn-sm btn-link text-danger p-0 load-remove" aria-label="Remove">&times;</button></td>' +
      '</tr>';
    }).join('');
  }

  function specNum(p, key) {
    var s = p && p.specs ? p.specs : {};
    var n = parseFloat(s[key]);
    return isNaN(n) ? 0 : n;
  }

  function kindOf(p) {
    return ((p && p.specs && p.specs.kind) || '').toLowerCase();
  }

  function roundUpStep(value, steps) {
    var i;
    for (i = 0; i < steps.length; i++) {
      if (steps[i] >= value) return steps[i];
    }
    return Math.ceil(value * 2) / 2;
  }

  function formatNaira(n) {
    return '₦' + (Number(n) || 0).toLocaleString();
  }

  function formatKwh(wh) {
    return (Math.round((wh / 1000) * 100) / 100).toFixed(2) + ' kWh';
  }

  function calculateSizes() {
    readRowsFromDom();
    var peakW = 0;
    var dailyWh = 0;
    rows.forEach(function(r) {
      var w = Number(r.watts) || 0;
      var q = Number(r.qty) || 0;
      var h = Number(r.hours) || 0;
      peakW += w * q;
      dailyWh += w * q * h;
    });
    var backupHours = Math.max(1, parseFloat(document.getElementById('backupHours').value) || 8);
    var inverterKvaRaw = (peakW * 1.25) / 1000;
    var inverterKva = roundUpStep(inverterKvaRaw, INVERTER_STEPS);
    var autonomyFactor = Math.max(backupHours / 24, 0.5);
    var batteryWh = dailyWh * autonomyFactor / DOD;
    var panelWatts = dailyWh / (PEAK_SUN_HOURS * SYSTEM_EFF);
    var voltage = inverterKva >= 5 ? 48 : (inverterKva >= 2.5 ? 24 : 12);
    var dcCurrent = voltage > 0 ? (inverterKva * 1000) / voltage : 0;
    var cableMm2 = dcCurrent > 40 ? 10 : 6;
    return {
      peakW: peakW,
      dailyWh: dailyWh,
      backupHours: backupHours,
      inverterKvaRaw: inverterKvaRaw,
      inverterKva: inverterKva,
      batteryWh: batteryWh,
      panelWatts: panelWatts,
      voltage: voltage,
      cableMm2: cableMm2
    };
  }

  function pickSmallestAtLeast(list, key, need) {
    var eligible = list.filter(function(p) { return specNum(p, key) >= need; })
      .sort(function(a, b) { return specNum(a, key) - specNum(b, key); });
    if (eligible.length) return { product: eligible[0], qty: 1 };
    var sorted = list.slice().sort(function(a, b) { return specNum(b, key) - specNum(a, key); });
    var largest = sorted[0];
    if (!largest) return { product: null, qty: 0 };
    var cap = specNum(largest, key);
    var qty = cap > 0 ? Math.max(1, Math.ceil(need / cap)) : 1;
    return { product: largest, qty: qty };
  }

  function matchKit(sizes) {
    var inverters = solarProducts.filter(function(p) { return kindOf(p) === 'inverter'; });
    var batteries = solarProducts.filter(function(p) { return kindOf(p) === 'battery'; });
    var stations = solarProducts.filter(function(p) { return kindOf(p) === 'powerstation'; });
    var panels = solarProducts.filter(function(p) { return kindOf(p) === 'panel' && specNum(p, 'watts') > 0; });
    var cables = solarProducts.filter(function(p) { return kindOf(p) === 'cable'; });

    var inverterPick = pickSmallestAtLeast(inverters, 'kva', sizes.inverterKva);
    var batteryPick = pickSmallestAtLeast(batteries, 'capacity_wh', sizes.batteryWh);
    if (!batteryPick.product) batteryPick = pickSmallestAtLeast(stations, 'capacity_wh', sizes.batteryWh);

    var panel = panels.slice().sort(function(a, b) { return specNum(b, 'watts') - specNum(a, 'watts'); })[0] || null;
    var panelWattsEach = panel ? specNum(panel, 'watts') : 0;
    var panelQty = panelWattsEach > 0 ? Math.max(1, Math.ceil(sizes.panelWatts / panelWattsEach)) : 0;

    var cableFit = cables.filter(function(p) { return specNum(p, 'cable_mm2') >= sizes.cableMm2; })
      .sort(function(a, b) { return specNum(a, 'cable_mm2') - specNum(b, 'cable_mm2'); });
    var cable = cableFit[0] || cables[0] || null;

    return {
      inverter: inverterPick.product,
      inverterQty: inverterPick.product ? inverterPick.qty : 0,
      battery: batteryPick.product,
      batteryQty: batteryPick.product ? batteryPick.qty : 0,
      panel: panel,
      panelQty: panelQty,
      cable: cable,
      cableQty: cable ? 1 : 0
    };
  }

  function productLine(p, qty, fallbackLabel) {
    if (!p) {
      return '<li class="solar-kit-item"><div><strong>' + safeHtml(fallbackLabel) + '</strong><p class="small text-muted mb-0">No matching product yet. <a href="shop.html?category=solar">Browse solar</a></p></div></li>';
    }
    var href = 'product.html?id=' + encodeURIComponent(p.id);
    var qtyLabel = qty > 1 ? qty + ' × ' : '';
    var price = formatNaira((p.price || 0) * (qty || 1));
    var img = p.image_url || '/images/solar/panel-array.jpg';
    if (esc && esc.url) img = esc.url(img) || img;
    else img = String(img).replace(/"/g, '&quot;');
    return '<li class="solar-kit-item">' +
      '<a href="' + href + '" class="solar-kit-thumb">' +
        '<img src="' + img + '" alt="">' +
      '</a>' +
      '<div class="flex-grow-1">' +
        '<a href="' + href + '" class="text-dark text-decoration-none fw-semibold">' + safeHtml(qtyLabel + (p.name || fallbackLabel)) + '</a>' +
        '<p class="small text-muted mb-0">' + price + '</p>' +
      '</div></li>';
  }

  function kitLinesText(sizes, kit) {
    var lines = [];
    lines.push('Peak load: ' + Math.round(sizes.peakW) + ' W');
    lines.push('Daily energy: ' + formatKwh(sizes.dailyWh));
    lines.push('Backup: ' + sizes.backupHours + ' hours');
    lines.push('');
    lines.push('Recommended:');
    lines.push('- Inverter: ~' + sizes.inverterKva + ' kVA' + (kit.inverter ? ' — ' + kit.inverter.name : ''));
    lines.push('- Battery: ~' + Math.round(sizes.batteryWh) + ' Wh' + (kit.battery ? ' — ' + (kit.batteryQty > 1 ? kit.batteryQty + ' × ' : '') + kit.battery.name : ''));
    lines.push('- Panels: ~' + Math.round(sizes.panelWatts) + ' W' + (kit.panel ? ' — ' + kit.panelQty + ' × ' + kit.panel.name : ''));
    lines.push('- Cable: ' + sizes.cableMm2 + ' mm²' + (kit.cable ? ' — ' + kit.cable.name : ''));
    return lines.join('\n');
  }

  function renderResults(sizes, kit) {
    var empty = document.getElementById('solarResultsEmpty');
    var body = document.getElementById('solarResultsBody');
    if (empty) empty.classList.add('d-none');
    if (body) body.classList.remove('d-none');

    var stats = document.getElementById('solarSummaryStats');
    if (stats) {
      stats.innerHTML =
        '<div class="col-6"><div class="solar-stat"><span class="solar-stat-label">Peak load</span><span class="solar-stat-value">' + Math.round(sizes.peakW).toLocaleString() + ' W</span></div></div>' +
        '<div class="col-6"><div class="solar-stat"><span class="solar-stat-label">Daily energy</span><span class="solar-stat-value">' + formatKwh(sizes.dailyWh) + '</span></div></div>';
    }

    var list = document.getElementById('solarKitList');
    if (list) {
      list.innerHTML =
        productLine(kit.inverter, kit.inverterQty, sizes.inverterKva + ' kVA inverter') +
        productLine(kit.battery, kit.batteryQty, Math.round(sizes.batteryWh) + ' Wh battery') +
        productLine(kit.panel, kit.panelQty, Math.round(sizes.panelWatts) + ' W solar array') +
        productLine(kit.cable, kit.cableQty, sizes.cableMm2 + ' mm² DC cable');
    }

    var note = document.getElementById('solarSizingNote');
    if (note) {
      note.textContent = 'Sized with 25% inverter headroom, lithium-style 80% depth of discharge, 4.5 peak-sun hours and 75% system efficiency. Guide only — a technician should confirm before install.';
    }

    var wa = document.getElementById('solarWhatsAppBtn');
    if (wa) {
      var msg = 'Hi Crypvilla, I used the solar calculator.\n\n' + kitLinesText(sizes, kit) + '\n\nPlease quote me.';
      wa.href = 'https://wa.me/' + WHATSAPP + '?text=' + encodeURIComponent(msg);
    }

    var cartMsg = document.getElementById('solarCartMsg');
    if (cartMsg) cartMsg.classList.add('d-none');
  }

  function addKitToCart() {
    if (!lastKit || !window.CrypvillaCart) return;
    var added = 0;
    function add(p, qty) {
      if (!p || !qty) return;
      var stock = parseInt(p.stock, 10);
      window.CrypvillaCart.add(p.id, qty, {
        name: p.name,
        price: p.price,
        image_url: p.image_url,
        category_slug: 'solar'
      }, isNaN(stock) ? null : stock);
      added += 1;
    }
    add(lastKit.inverter, lastKit.inverterQty);
    add(lastKit.battery, lastKit.batteryQty);
    add(lastKit.panel, lastKit.panelQty);
    add(lastKit.cable, lastKit.cableQty);
    updateCartCount();
    var msg = document.getElementById('solarCartMsg');
    if (msg) {
      if (added === 0) {
        msg.innerHTML = 'No matching products to add yet. <a href="shop.html?category=solar">Browse solar</a>';
      } else {
        msg.innerHTML = 'Kit added to cart. <a href="cart.html">View cart</a>';
      }
      msg.classList.remove('d-none');
    }
  }

  function loadSolarProducts() {
    if (!window.supabase) return Promise.resolve([]);
    return window.supabase.from('products')
      .select('id, name, slug, price, image_url, specs, stock, categories!inner(slug)')
      .eq('categories.slug', 'solar')
      .then(function(r) {
        solarProducts = r.data || [];
        return solarProducts;
      })
      .catch(function() {
        solarProducts = [];
        return solarProducts;
      });
  }

  function onCalculate() {
    lastSizes = calculateSizes();
    lastKit = matchKit(lastSizes);
    renderResults(lastSizes, lastKit);
  }

  function bind() {
    var tbody = document.getElementById('solarLoadRows');
    if (tbody) {
      tbody.addEventListener('change', function(e) {
        var tr = e.target.closest('tr');
        if (!tr) return;
        if (e.target.classList.contains('load-name')) {
          var id = parseInt(tr.getAttribute('data-id'), 10);
          var row = rows.filter(function(r) { return r.id === id; })[0];
          if (row) {
            row.name = e.target.value;
            row.watts = wattsForName(row.name);
            var wattsEl = tr.querySelector('.load-watts');
            if (wattsEl) wattsEl.value = row.watts;
          }
        }
        readRowsFromDom();
      });
      tbody.addEventListener('click', function(e) {
        var btn = e.target.closest('.load-remove');
        if (!btn) return;
        var tr = btn.closest('tr');
        var id = parseInt(tr.getAttribute('data-id'), 10);
        if (rows.length <= 1) return;
        rows = rows.filter(function(r) { return r.id !== id; });
        renderRows();
      });
    }

    var addBtn = document.getElementById('solarAddRow');
    if (addBtn) {
      addBtn.addEventListener('click', function() {
        readRowsFromDom();
        rows.push({ id: nextId++, name: 'LED bulb', watts: 10, qty: 1, hours: 4 });
        renderRows();
      });
    }

    var calcBtn = document.getElementById('solarCalculateBtn');
    if (calcBtn) calcBtn.addEventListener('click', onCalculate);

    var kitBtn = document.getElementById('solarAddKitBtn');
    if (kitBtn) kitBtn.addEventListener('click', addKitToCart);

    window.addEventListener('crypvilla:cartUpdate', updateCartCount);
  }

  rows = defaultRows();
  renderRows();
  bind();
  updateCartCount();
  onCalculate();
  loadSolarProducts().then(function() { onCalculate(); });
})();
