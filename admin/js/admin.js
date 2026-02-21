(function() {
  var config = window.CRYPVILLA_ADMIN_CONFIG;
  var supabase = null;
  var categories = [];
  var currentOrderId = null;
  var productCurrentImages = [];
  var productPendingFiles = [];
  var productPendingPreviews = [];

  function initSupabase() {
    if (!config || !config.SUPABASE_URL || !config.SUPABASE_ANON_KEY) {
      document.getElementById('alertConfig').classList.remove('d-none');
      return;
    }
    if (supabase) return; // Reuse existing client to avoid multiple GoTrueClient instances
    document.getElementById('alertConfig').classList.add('d-none');
    try {
      supabase = window.supabase.createClient(config.SUPABASE_URL, config.SUPABASE_ANON_KEY);
    } catch (e) {
      console.error('Admin Supabase init failed', e);
      document.getElementById('alertConfig').classList.remove('d-none');
    }
  }

  function showApp() {
    document.getElementById('loginView').classList.add('d-none');
    document.getElementById('adminApp').classList.remove('d-none');
    initSupabase();
    loadDashboard();
    loadProducts();
  }

  function showLogin() {
    document.getElementById('adminApp').classList.add('d-none');
    document.getElementById('loginView').classList.remove('d-none');
    document.getElementById('loginError').classList.add('d-none');
  }

  function showTestResult(ok, message) {
    var el = document.getElementById('testSupabaseResult');
    if (!el) return;
    el.classList.remove('d-none');
    el.className = 'mb-2 small ' + (ok ? 'text-success' : 'text-danger');
    el.textContent = message;
  }

  function testSupabaseConnection() {
    var config = window.CRYPVILLA_ADMIN_CONFIG;
    if (!config || !config.SUPABASE_URL || !config.SUPABASE_ANON_KEY) {
      showTestResult(false, 'Config missing: set SUPABASE_URL and SUPABASE_ANON_KEY in admin/config.js');
      return;
    }
    if (!supabase) {
      showTestResult(false, 'Sign in first, then test connection.');
      return;
    }
    showTestResult(true, 'Checking…');
    supabase.from('categories').select('id').limit(1).then(function(r) {
      if (r.error) {
        showTestResult(false, 'Connection failed: ' + (r.error.message || r.error.code) + '. Run schema-admin-auth.sql and add your user to admin_users.');
        return;
      }
      showTestResult(true, 'Supabase connection OK. You have admin access.');
    }).catch(function(e) {
      showTestResult(false, 'Error: ' + (e.message || e));
    });
  }

  function checkAdminList() {
    var el = document.getElementById('checkAdminListResult');
    if (!el) return;
    el.classList.remove('d-none');
    el.className = 'mb-2 small text-muted';
    el.textContent = 'Checking…';
    if (!supabase) {
      el.className = 'mb-2 small text-danger';
      el.textContent = 'Sign in first.';
      return;
    }
    supabase.from('admin_users').select('user_id').limit(1).single().then(function(r) {
      if (r.error && r.error.code === 'PGRST116') {
        return supabase.auth.getSession().then(function(sr) {
          var email = (sr.data && sr.data.session && sr.data.session.user && sr.data.session.user.email) ? sr.data.session.user.email : 'your@email.com';
          el.className = 'mb-2 small text-danger';
          el.textContent = 'You are NOT in the admin list. Image upload will fail. In Supabase SQL Editor run: SELECT add_admin_by_email(\'' + email + '\');';
        });
      }
      if (r.error) {
        el.className = 'mb-2 small text-danger';
        el.textContent = 'Error: ' + (r.error.message || r.error.code);
        return;
      }
      el.className = 'mb-2 small text-success';
      el.textContent = 'You are in the admin list. Storage upload should work.';
    }).catch(function(e) {
      el.className = 'mb-2 small text-danger';
      el.textContent = 'Error: ' + (e.message || e);
    });
  }

  function formatNaira(n) {
    return '₦' + (Number(n) || 0).toLocaleString();
  }

  function makeSlug(name) {
    return (name || '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'product';
  }

  function statusBadge(status) {
    var s = (status || 'pending').toLowerCase();
    var cls = 'badge-status badge-pending';
    if (s === 'paid') cls = 'badge-status badge-paid';
    else if (s === 'shipped') cls = 'badge-status badge-shipped';
    else if (s === 'delivered') cls = 'badge-status badge-delivered';
    else if (s === 'cancelled') cls = 'badge-status badge-cancelled';
    return '<span class="' + cls + '">' + (status || 'pending') + '</span>';
  }

  // ——— Page navigation ———
  var pageTitles = {
    dashboard: 'Dashboard',
    products: 'Products',
    orders: 'Orders',
    offers: 'Offers',
    customers: 'Customers'
  };
  document.querySelectorAll('.admin-sidebar .nav-link').forEach(function(link) {
    link.addEventListener('click', function(e) {
      e.preventDefault();
      var page = link.getAttribute('data-page');
      document.querySelectorAll('.admin-sidebar .nav-link').forEach(function(l) { l.classList.remove('active'); });
      link.classList.add('active');
      document.querySelectorAll('.admin-page').forEach(function(p) { p.classList.remove('active'); });
      var panel = document.getElementById('page' + page.charAt(0).toUpperCase() + page.slice(1));
      if (panel) panel.classList.add('active');
      document.getElementById('adminPageTitle').textContent = pageTitles[page] || page;
      if (page === 'products') loadProducts();
      if (page === 'orders') loadOrders();
      if (page === 'offers') loadOffers();
      if (page === 'customers') loadCustomers();
      if (page === 'dashboard') loadDashboard();
    });
  });

  // ——— Dashboard ———
  function loadDashboard() {
    if (!supabase) return;
    Promise.all([
      supabase.from('products').select('id', { count: 'exact', head: true }),
      supabase.from('orders').select('id', { count: 'exact', head: true }),
      supabase.from('orders').select('customer_email')
    ]).then(function(results) {
      var productCount = (results[0] && results[0].count) || 0;
      var orderCount = (results[1] && results[1].count) || 0;
      var emails = (results[2] && results[2].data) || [];
      var uniqueEmails = new Set(emails.map(function(o) { return o.customer_email; }).filter(Boolean));
      document.getElementById('statProducts').textContent = productCount;
      document.getElementById('statOrders').textContent = orderCount;
      document.getElementById('statCustomers').textContent = uniqueEmails.size;
    }).catch(function(err) {
      console.error(err);
      document.getElementById('statProducts').textContent = '—';
      document.getElementById('statOrders').textContent = '—';
      document.getElementById('statCustomers').textContent = '—';
    });
  }

  // ——— Categories ———
  function loadCategories() {
    if (!supabase) return Promise.resolve([]);
    return supabase.from('categories').select('id, slug, name').order('sort_order').then(function(r) {
      categories = (r.data || []);
      return categories;
    });
  }

  // ——— Products (with search and category filter) ———
  var allProductsList = [];

  function getProductFilter() {
    var searchEl = document.getElementById('productSearch');
    var categoryEl = document.getElementById('productCategoryFilter');
    return {
      search: (searchEl && searchEl.value) ? searchEl.value.trim().toLowerCase() : '',
      categoryId: (categoryEl && categoryEl.value) ? categoryEl.value : ''
    };
  }

  function filterProducts(list) {
    var filter = getProductFilter();
    return (list || []).filter(function(p) {
      if (filter.categoryId && p.category_id !== filter.categoryId) return false;
      if (!filter.search) return true;
      var name = (p.name || '').toLowerCase();
      var desc = (p.description || '').toLowerCase();
      return name.indexOf(filter.search) >= 0 || desc.indexOf(filter.search) >= 0;
    });
  }

  function renderProductsTable(list) {
    var tbody = document.getElementById('productsTableBody');
    if (!tbody) return;
    var catMap = {};
    categories.forEach(function(c) { catMap[c.id] = c.name; });
    if (!list || list.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="text-muted">No products match. Try a different search or category.</td></tr>';
      return;
    }
    tbody.innerHTML = list.map(function(p) {
      var img = p.image_url
        ? '<img src="' + p.image_url + '" alt="" style="width:48px;height:48px;object-fit:cover;border-radius:6px;">'
        : '<span class="text-muted">—</span>';
      var catName = catMap[p.category_id] || '—';
      return '<tr>' +
        '<td>' + img + '</td>' +
        '<td>' + (p.name || '') + '</td>' +
        '<td>' + catName + '</td>' +
        '<td>' + formatNaira(p.price) + '</td>' +
        '<td>' + (p.stock ?? '—') + '</td>' +
        '<td><button type="button" class="btn-admin-outline btn-sm edit-product" data-id="' + p.id + '">Edit</button> ' +
        '<button type="button" class="btn-admin-danger btn-sm delete-product" data-id="' + p.id + '">Delete</button></td>' +
        '</tr>';
    }).join('');
    bindProductButtons();
  }

  function loadProducts() {
    var tbody = document.getElementById('productsTableBody');
    if (!supabase) {
      if (tbody) tbody.innerHTML = '<tr><td colspan="6">Configure admin/config.js</td></tr>';
      return;
    }
    loadCategories().then(function() {
      var catFilter = document.getElementById('productCategoryFilter');
      if (catFilter && categories.length) {
        catFilter.innerHTML = '<option value="">All categories</option>' + categories.map(function(c) {
          return '<option value="' + c.id + '">' + (c.name || c.slug) + '</option>';
        }).join('');
      }
      return supabase.from('products').select('id, name, slug, price, stock, image_url, category_id, description').order('created_at', { ascending: false });
    }).then(function(r) {
      if (r.error) {
        tbody.innerHTML = '<tr><td colspan="6">Error: ' + (r.error.message || 'Failed to load') + '</td></tr>';
        return;
      }
      allProductsList = r.data || [];
      var filtered = filterProducts(allProductsList);
      if (allProductsList.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6">No products. Click Add product.</td></tr>';
        return;
      }
      renderProductsTable(filtered);
    }).catch(function(err) {
      tbody.innerHTML = '<tr><td colspan="6">Error loading products</td></tr>';
      console.error(err);
    });
  }

  (function bindProductSearchAndFilter() {
    var searchEl = document.getElementById('productSearch');
    var categoryEl = document.getElementById('productCategoryFilter');
    if (searchEl) {
      searchEl.addEventListener('input', function() {
        renderProductsTable(filterProducts(allProductsList));
      });
    }
    if (categoryEl) {
      categoryEl.addEventListener('change', function() {
        renderProductsTable(filterProducts(allProductsList));
      });
    }
  })();

  function bindProductButtons() {
    document.querySelectorAll('.edit-product').forEach(function(btn) {
      btn.addEventListener('click', function() { openProductModal(btn.getAttribute('data-id')); });
    });
    document.querySelectorAll('.delete-product').forEach(function(btn) {
      btn.addEventListener('click', function() {
        if (confirm('Delete this product?')) deleteProduct(btn.getAttribute('data-id'));
      });
    });
  }

  function deleteProduct(id) {
    if (!supabase) return;
    supabase.from('products').delete().eq('id', id).then(function(r) {
      if (r.error) alert('Delete failed: ' + r.error.message);
      else loadProducts();
    });
  }

  function openProductModal(id) {
    var title = document.getElementById('productModalTitle');
    var form = document.getElementById('productForm');
    form.reset();
    document.getElementById('productId').value = id || '';
    document.getElementById('productSlug').value = '';
    productCurrentImages = [];
    productPendingFiles = [];
    productPendingPreviews.forEach(function(u) { try { URL.revokeObjectURL(u); } catch (e) {} });
    productPendingPreviews = [];
    document.getElementById('productImageFiles').value = '';
    title.textContent = id ? 'Edit product' : 'Add product';

    var catSelect = document.getElementById('productCategory');
    catSelect.innerHTML = '<option value="">Select category</option>' + categories.map(function(c) {
      return '<option value="' + c.id + '">' + (c.name || c.slug) + '</option>';
    }).join('');

    if (id) {
      supabase.from('products').select('*').eq('id', id).single().then(function(r) {
        if (r.data) {
          var p = r.data;
          document.getElementById('productCategory').value = p.category_id;
          document.getElementById('productName').value = p.name || '';
          document.getElementById('productSlug').value = p.slug || makeSlug(p.name);
          document.getElementById('productDescription').value = p.description || '';
          document.getElementById('productPrice').value = p.price ?? '';
          document.getElementById('productCompareAt').value = p.compare_at_price ?? '';
          document.getElementById('productStock').value = p.stock ?? 0;
          var imgs = Array.isArray(p.images) && p.images.length ? p.images : (p.image_url ? [p.image_url] : []);
          productCurrentImages = imgs.slice();
          renderProductImagesList();
          var spec = (typeof p.specs === 'object' && p.specs !== null) ? p.specs : {};
          document.getElementById('productSpecProcessor').value = spec.processor || '';
          document.getElementById('productSpecRam').value = spec.ram || '';
          document.getElementById('productSpecStorage').value = spec.storage || '';
        }
      });
    } else {
      renderProductImagesList();
    }
    document.getElementById('productModal').classList.add('show');
  }

  function closeProductModal() {
    document.getElementById('productModal').classList.remove('show');
  }

  document.getElementById('btnAddProduct').addEventListener('click', function() { openProductModal(null); });
  document.getElementById('productModalClose').addEventListener('click', closeProductModal);
  document.getElementById('productModalCancel').addEventListener('click', closeProductModal);
  document.getElementById('productModal').addEventListener('click', function(e) {
    if (e.target === document.getElementById('productModal')) closeProductModal();
  });

  function renderProductImagesList() {
    var list = document.getElementById('productImagesList');
    list.innerHTML = '';
    productCurrentImages.forEach(function(url, i) {
      var wrap = document.createElement('div');
      wrap.className = 'product-img-thumb';
      wrap.innerHTML = '<img src="' + (url || '').replace(/"/g, '&quot;') + '" alt=""><button type="button" class="img-remove" data-type="url" data-i="' + i + '" aria-label="Remove">&times;</button>';
      list.appendChild(wrap);
    });
    productPendingFiles.forEach(function(file, i) {
      var wrap = document.createElement('div');
      wrap.className = 'product-img-thumb';
      var url = productPendingPreviews[i] || '';
      wrap.innerHTML = '<img src="' + url.replace(/"/g, '&quot;') + '" alt=""><button type="button" class="img-remove" data-type="file" data-i="' + i + '" aria-label="Remove">&times;</button>';
      list.appendChild(wrap);
    });
    list.querySelectorAll('.img-remove').forEach(function(btn) {
      btn.addEventListener('click', function() {
        var type = btn.getAttribute('data-type');
        var idx = parseInt(btn.getAttribute('data-i'), 10);
        if (type === 'url') {
          productCurrentImages.splice(idx, 1);
        } else {
          if (productPendingPreviews[idx]) try { URL.revokeObjectURL(productPendingPreviews[idx]); } catch (e) {}
          productPendingFiles.splice(idx, 1);
          productPendingPreviews.splice(idx, 1);
        }
        renderProductImagesList();
      });
    });
  }

  document.getElementById('productImageFiles').addEventListener('change', function() {
    var files = this.files;
    if (!files || !files.length) return;
    for (var i = 0; i < files.length; i++) {
      productPendingFiles.push(files[i]);
      productPendingPreviews.push(URL.createObjectURL(files[i]));
    }
    this.value = '';
    renderProductImagesList();
  });

  document.getElementById('productModalSave').addEventListener('click', function() {
    var id = document.getElementById('productId').value.trim();
    var categoryId = document.getElementById('productCategory').value;
    var name = document.getElementById('productName').value.trim();
    var description = document.getElementById('productDescription').value.trim();
    var price = parseFloat(document.getElementById('productPrice').value) || 0;
    var compareAt = document.getElementById('productCompareAt').value.trim();
    var stock = parseInt(document.getElementById('productStock').value, 10) || 0;

    if (!categoryId || !name) {
      alert('Category and name are required.');
      return;
    }

    var specs = {
      processor: document.getElementById('productSpecProcessor').value.trim() || undefined,
      ram: document.getElementById('productSpecRam').value.trim() || undefined,
      storage: document.getElementById('productSpecStorage').value.trim() || undefined
    };
    if (!specs.processor && !specs.ram && !specs.storage) specs = {};

    var slug = document.getElementById('productSlug').value.trim() || makeSlug(name);
    var payload = {
      category_id: categoryId,
      name: name,
      slug: slug,
      description: description || null,
      price: price,
      compare_at_price: compareAt ? parseFloat(compareAt) : null,
      stock: stock,
      specs: specs,
      updated_at: new Date().toISOString()
    };

    function doUpsert(finalUrls) {
      payload.images = finalUrls || [];
      payload.image_url = (finalUrls && finalUrls[0]) || null;
      var promise = id
        ? supabase.from('products').update(payload).eq('id', id)
        : supabase.from('products').insert(payload);
      promise.then(function(r) {
        if (r.error) alert('Save failed: ' + r.error.message);
        else { closeProductModal(); loadProducts(); loadDashboard(); }
      });
    }

    var existingUrls = productCurrentImages.slice();
    if (productPendingFiles.length === 0) {
      doUpsert(existingUrls.length ? existingUrls : null);
      return;
    }
    var prefix = 'products/' + (id || 'new') + '-';
    var uploaded = 0;
    var newUrls = [];
    function next() {
      if (uploaded >= productPendingFiles.length) {
        doUpsert(existingUrls.concat(newUrls));
        return;
      }
      var file = productPendingFiles[uploaded];
      var ext = (file.name.split('.').pop() || 'jpg').toLowerCase().replace(/[^a-z0-9]/g, '') || 'jpg';
      var path = prefix + Date.now() + '-' + uploaded + '.' + ext;
      var uploadOpts = { upsert: true };
      if (file.type) uploadOpts.contentType = file.type;
      supabase.storage.from(config.STORAGE_BUCKET).upload(path, file, uploadOpts).then(function(up) {
        if (up.error) {
          var msg = up.error.message || up.error.error || 'Image upload failed';
          var errLower = (up.error.message || '').toLowerCase();
          if (errLower.indexOf('row-level security') !== -1 || errLower.indexOf('row level security') !== -1 || (up.error.message && up.error.message.indexOf('violates') !== -1)) {
            supabase.auth.getSession().then(function(sr) {
              var email = (sr.data && sr.data.session && sr.data.session.user && sr.data.session.user.email) ? sr.data.session.user.email : 'your@email.com';
              msg = 'Storage denied: your user is not in the admin list. In Supabase SQL Editor run: SELECT add_admin_by_email(\'' + email + '\');';
              alert(msg);
              doUpsert(existingUrls.length ? existingUrls : null);
            }).catch(function() {
              alert(msg);
              doUpsert(existingUrls.length ? existingUrls : null);
            });
            return;
          }
          if (up.error.message && up.error.message.indexOf('400') !== -1) {
            msg += ' (400). Ensure the Storage bucket "' + (config.STORAGE_BUCKET || 'product-images') + '" exists in Supabase Dashboard, is Public, and storage RLS policies from schema-admin-auth.sql are applied.';
          }
          alert(msg);
          doUpsert(existingUrls.length ? existingUrls : null);
          return;
        }
        var pub = supabase.storage.from(config.STORAGE_BUCKET).getPublicUrl(path);
        newUrls.push(pub.data.publicUrl);
        uploaded++;
        next();
      });
    }
    next();
  });

  // ——— Orders ———
  function loadOrders() {
    var tbody = document.getElementById('ordersTableBody');
    if (!supabase) {
      tbody.innerHTML = '<tr><td colspan="6">Configure admin/config.js</td></tr>';
      return;
    }
    supabase.from('orders').select('id, order_number, customer_name, customer_email, total, status, created_at')
      .order('created_at', { ascending: false })
      .then(function(r) {
        if (r.error) {
          tbody.innerHTML = '<tr><td colspan="6">Error: ' + (r.error.message || 'Failed to load') + '</td></tr>';
          return;
        }
        var list = r.data || [];
        if (list.length === 0) {
          tbody.innerHTML = '<tr><td colspan="6">No orders yet.</td></tr>';
          return;
        }
        tbody.innerHTML = list.map(function(o) {
          var date = o.created_at ? new Date(o.created_at).toLocaleDateString() : '—';
          return '<tr>' +
            '<td>' + (o.order_number || o.id) + '</td>' +
            '<td>' + (o.customer_name || '') + ' <small class="text-muted">' + (o.customer_email || '') + '</small></td>' +
            '<td>' + formatNaira(o.total) + '</td>' +
            '<td>' + statusBadge(o.status) + '</td>' +
            '<td>' + date + '</td>' +
            '<td><button type="button" class="btn-admin-outline btn-sm view-order" data-id="' + o.id + '">View</button></td>' +
            '</tr>';
        }).join('');
        document.querySelectorAll('.view-order').forEach(function(btn) {
          btn.addEventListener('click', function() { openOrderModal(btn.getAttribute('data-id')); });
        });
      }).catch(function(err) {
        tbody.innerHTML = '<tr><td colspan="6">Error loading orders</td></tr>';
        console.error(err);
      });
  }

  function openOrderModal(id) {
    currentOrderId = id;
    document.getElementById('orderModalTitle').textContent = 'Order details';
    document.getElementById('orderModalBody').innerHTML = '<p class="text-muted">Loading…</p>';
    document.getElementById('orderModal').classList.add('show');

    supabase.from('orders').select('*').eq('id', id).single().then(function(orderRes) {
      if (orderRes.error || !orderRes.data) {
        document.getElementById('orderModalBody').innerHTML = '<p>Order not found.</p>';
        return;
      }
      var o = orderRes.data;
      return supabase.from('order_items').select('*').eq('order_id', id).then(function(itemsRes) {
        var items = (itemsRes.data || []);
        var logoUrl = '../images/crypvilla-removebg-preview.png';
        var content = '<p><strong>Order #</strong> ' + (o.order_number || o.id) + '</p>' +
          '<p><strong>Customer:</strong> ' + (o.customer_name || '') + '<br><strong>Email:</strong> ' + (o.customer_email || '') + '<br><strong>Phone:</strong> ' + (o.customer_phone || '') + '</p>' +
          '<p><strong>Delivery address:</strong><br>' + (o.delivery_address || '') + '</p>' +
          '<p><strong>Subtotal:</strong> ' + formatNaira(o.subtotal) + ' &nbsp; <strong>Shipping:</strong> ' + formatNaira(o.shipping) + ' &nbsp; <strong>Total:</strong> ' + formatNaira(o.total) + '</p>' +
          '<p><strong>Paystack ref:</strong> ' + (o.paystack_reference || o.payaza_reference || '—') + ' &nbsp; <strong>Status:</strong> ' + (o.paystack_status || o.payaza_status || '—') + '</p>' +
          '<table class="admin-table order-print-table mt-2"><thead><tr><th>Item</th><th>Qty</th><th>Price</th></tr></thead><tbody>';
        items.forEach(function(i) {
          var snap = i.product_snapshot || {};
          content += '<tr><td>' + (snap.name || 'Product') + '</td><td>' + i.quantity + '</td><td>' + formatNaira(i.price) + '</td></tr>';
        });
        content += '</tbody></table>';
        var html = '<div class="order-print-wrap">' +
          '<div class="order-print-header"><img src="' + logoUrl + '" alt="Crypvilla" class="order-print-logo"><h2 class="order-print-title">Crypvilla</h2><p class="order-print-subtitle">Order details</p></div>' +
          '<div class="order-print-content">' + content + '</div></div>';
        document.getElementById('orderModalBody').innerHTML = html;
        document.getElementById('orderStatusSelect').value = o.status || 'pending';
      });
    });
  }

  document.getElementById('orderModalClose').addEventListener('click', function() {
    document.getElementById('orderModal').classList.remove('show');
  });
  document.getElementById('orderModal').addEventListener('click', function(e) {
    if (e.target === document.getElementById('orderModal')) document.getElementById('orderModal').classList.remove('show');
  });
  document.getElementById('orderModalPrint').addEventListener('click', function() {
    window.print();
  });
  document.getElementById('orderModalSaveStatus').addEventListener('click', function() {
    if (!currentOrderId || !supabase) return;
    var status = document.getElementById('orderStatusSelect').value;
    supabase.from('orders').update({ status: status }).eq('id', currentOrderId).then(function(r) {
      if (r.error) alert('Update failed: ' + r.error.message);
      else { loadOrders(); document.getElementById('orderModal').classList.remove('show'); }
    });
  });

  // ——— Offers ———
  var allOffersList = [];

  function offerStatusBadge(status) {
    var s = (status || '').toLowerCase();
    var cls = 'badge-status badge-pending';
    if (s === 'approved') cls = 'badge-status badge-paid';
    else if (s === 'countered') cls = 'badge-status badge-shipped';
    else if (s === 'rejected' || s === 'expired') cls = 'badge-status badge-cancelled';
    else if (s === 'completed') cls = 'badge-status badge-delivered';
    return '<span class="' + cls + '">' + (status || 'pending') + '</span>';
  }

  function generateCheckoutToken() {
    var arr = new Uint8Array(32);
    if (typeof crypto !== 'undefined' && crypto.getRandomValues) {
      crypto.getRandomValues(arr);
    } else {
      for (var i = 0; i < 32; i++) arr[i] = Math.floor(Math.random() * 256);
    }
    return Array.from(arr).map(function(b) { return ('0' + b.toString(16)).slice(-2); }).join('');
  }

  function loadOffers() {
    var tbody = document.getElementById('offersTableBody');
    var statusFilter = document.getElementById('offerStatusFilter');
    if (!supabase) {
      if (tbody) tbody.innerHTML = '<tr><td colspan="10">Configure admin/config.js</td></tr>';
      return;
    }
    supabase.from('offers').select('*, products(name, slug)').order('created_at', { ascending: false })
      .then(function(r) {
        if (r.error) {
          tbody.innerHTML = '<tr><td colspan="10">Error: ' + (r.error.message || 'Failed to load') + '</td></tr>';
          return;
        }
        allOffersList = r.data || [];
        var filterStatus = (statusFilter && statusFilter.value) ? statusFilter.value : '';
        var list = filterStatus ? allOffersList.filter(function(o) { return o.status === filterStatus; }) : allOffersList;
        if (list.length === 0) {
          tbody.innerHTML = '<tr><td colspan="10" class="text-muted">No offers' + (filterStatus ? ' with this status.' : ' yet.') + '</td></tr>';
          return;
        }
        tbody.innerHTML = list.map(function(o) {
          var product = o.products;
          var productName = (product && product.name) ? product.name : (o.product_id || '—');
          var date = o.created_at ? new Date(o.created_at).toLocaleString() : '—';
          var qty = o.quantity != null ? o.quantity : 1;
          var reason = (o.reason || '').trim();
          var reasonCell = reason ? ('<span title="' + reason.replace(/"/g, '&quot;') + '">' + (reason.length > 40 ? reason.substring(0, 40) + '…' : reason) + '</span>') : '—';
          var canAct = (o.status === 'pending' || o.status === 'countered');
          var actions = canAct
            ? '<button type="button" class="btn-admin-outline btn-sm approve-offer" data-id="' + o.id + '">Approve</button> ' +
              '<button type="button" class="btn-admin-danger btn-sm reject-offer" data-id="' + o.id + '">Reject</button>'
            : '—';
          return '<tr>' +
            '<td>' + date + '</td>' +
            '<td>' + productName + '</td>' +
            '<td>' + qty + '</td>' +
            '<td>' + (o.email || '—') + '</td>' +
            '<td>' + formatNaira(o.original_price) + '</td>' +
            '<td>' + formatNaira(o.offered_price) + '</td>' +
            '<td style="max-width: 160px;" class="text-muted small">' + reasonCell + '</td>' +
            '<td>' + (o.counter_price != null ? formatNaira(o.counter_price) : '—') + '</td>' +
            '<td>' + offerStatusBadge(o.status) + '</td>' +
            '<td>' + actions + '</td>' +
            '</tr>';
        }).join('');
        document.querySelectorAll('.approve-offer').forEach(function(btn) {
          btn.addEventListener('click', function() { adminApproveOffer(btn.getAttribute('data-id')); });
        });
        document.querySelectorAll('.reject-offer').forEach(function(btn) {
          btn.addEventListener('click', function() { adminRejectOffer(btn.getAttribute('data-id')); });
        });
      }).catch(function(err) {
        tbody.innerHTML = '<tr><td colspan="10">Error loading offers</td></tr>';
        console.error(err);
      });
  }

  function adminApproveOffer(offerId) {
    if (!supabase) return;
    var token = generateCheckoutToken();
    var twoDaysMs = 2 * 24 * 60 * 60 * 1000;
    var expiresAt = new Date(Date.now() + twoDaysMs).toISOString();
    supabase.from('offers').update({
      status: 'approved',
      counter_price: null,
      checkout_token: token,
      checkout_token_expires_at: expiresAt
    }).eq('id', offerId).then(function(r) {
      if (r.error) alert('Approve failed: ' + r.error.message);
      else loadOffers();
    });
  }

  var rejectOfferModalOfferId = null;

  function adminRejectOffer(offerId) {
    rejectOfferModalOfferId = offerId;
    var modal = document.getElementById('rejectOfferModal');
    var msgEl = document.getElementById('rejectOfferMessage');
    var priceEl = document.getElementById('rejectOfferBestPrice');
    if (msgEl) msgEl.value = '';
    if (priceEl) priceEl.value = '';
    if (modal) modal.style.display = 'flex';
  }

  function closeRejectOfferModal() {
    rejectOfferModalOfferId = null;
    var modal = document.getElementById('rejectOfferModal');
    if (modal) modal.style.display = 'none';
  }

  function confirmRejectOffer() {
    if (!supabase || !rejectOfferModalOfferId) return;
    var msgEl = document.getElementById('rejectOfferMessage');
    var priceEl = document.getElementById('rejectOfferBestPrice');
    var rejection_message = (msgEl && msgEl.value) ? msgEl.value.trim() : null;
    var counter_price = null;
    if (priceEl && priceEl.value !== '' && !isNaN(parseFloat(priceEl.value))) {
      var n = parseFloat(priceEl.value);
      if (n >= 0) counter_price = n;
    }
    var payload = {
      status: 'rejected',
      checkout_token: null,
      checkout_token_expires_at: null,
      rejection_message: rejection_message || null,
      counter_price: counter_price
    };
    supabase.from('offers').update(payload).eq('id', rejectOfferModalOfferId).then(function(r) {
      if (r.error) alert('Reject failed: ' + r.error.message);
      else loadOffers();
      closeRejectOfferModal();
    });
  }

  (function setupRejectOfferModal() {
    var modal = document.getElementById('rejectOfferModal');
    var closeBtn = document.getElementById('rejectOfferModalClose');
    var cancelBtn = document.getElementById('rejectOfferCancel');
    var confirmBtn = document.getElementById('rejectOfferConfirm');
    if (closeBtn) closeBtn.addEventListener('click', closeRejectOfferModal);
    if (cancelBtn) cancelBtn.addEventListener('click', closeRejectOfferModal);
    if (confirmBtn) confirmBtn.addEventListener('click', confirmRejectOffer);
    if (modal) modal.addEventListener('click', function(e) { if (e.target === modal) closeRejectOfferModal(); });
  })();

  var offerStatusFilterEl = document.getElementById('offerStatusFilter');
  if (offerStatusFilterEl) {
    offerStatusFilterEl.addEventListener('change', function() {
      var tbody = document.getElementById('offersTableBody');
      if (!tbody || !allOffersList.length) return;
      var filterStatus = this.value;
      var list = filterStatus ? allOffersList.filter(function(o) { return o.status === filterStatus; }) : allOffersList;
      if (list.length === 0) {
        tbody.innerHTML = '<tr><td colspan="10" class="text-muted">No offers with this status.</td></tr>';
        return;
      }
      tbody.innerHTML = list.map(function(o) {
        var product = o.products;
        var productName = (product && product.name) ? product.name : (o.product_id || '—');
        var date = o.created_at ? new Date(o.created_at).toLocaleString() : '—';
        var qty = o.quantity != null ? o.quantity : 1;
        var reason = (o.reason || '').trim();
        var reasonCell = reason ? ('<span title="' + reason.replace(/"/g, '&quot;') + '">' + (reason.length > 40 ? reason.substring(0, 40) + '…' : reason) + '</span>') : '—';
        var canAct = (o.status === 'pending' || o.status === 'countered');
        var actions = canAct
          ? '<button type="button" class="btn-admin-outline btn-sm approve-offer" data-id="' + o.id + '">Approve</button> ' +
            '<button type="button" class="btn-admin-danger btn-sm reject-offer" data-id="' + o.id + '">Reject</button>'
          : '—';
        return '<tr>' +
          '<td>' + date + '</td>' +
          '<td>' + productName + '</td>' +
          '<td>' + qty + '</td>' +
          '<td>' + (o.email || '—') + '</td>' +
          '<td>' + formatNaira(o.original_price) + '</td>' +
          '<td>' + formatNaira(o.offered_price) + '</td>' +
          '<td style="max-width: 160px;" class="text-muted small">' + reasonCell + '</td>' +
          '<td>' + (o.counter_price != null ? formatNaira(o.counter_price) : '—') + '</td>' +
          '<td>' + offerStatusBadge(o.status) + '</td>' +
          '<td>' + actions + '</td>' +
          '</tr>';
      }).join('');
      document.querySelectorAll('.approve-offer').forEach(function(btn) {
        btn.addEventListener('click', function() { adminApproveOffer(btn.getAttribute('data-id')); });
      });
      document.querySelectorAll('.reject-offer').forEach(function(btn) {
        btn.addEventListener('click', function() { adminRejectOffer(btn.getAttribute('data-id')); });
      });
    });
  }

  // ——— Customers (from orders) ———
  function loadCustomers() {
    var tbody = document.getElementById('customersTableBody');
    if (!supabase) {
      tbody.innerHTML = '<tr><td colspan="5">Configure admin/config.js</td></tr>';
      return;
    }
    supabase.from('orders').select('customer_name, customer_email, customer_phone, created_at, order_number')
      .order('created_at', { ascending: false })
      .then(function(r) {
        if (r.error) {
          tbody.innerHTML = '<tr><td colspan="5">Error loading orders</td></tr>';
          return;
        }
        var orders = r.data || [];
        var byEmail = {};
        orders.forEach(function(o) {
          var email = (o.customer_email || '').trim().toLowerCase();
          if (!email) return;
          if (!byEmail[email]) {
            byEmail[email] = { name: o.customer_name, email: o.customer_email, phone: o.customer_phone, orders: 0, lastOrder: null, lastOrderNumber: null };
          }
          byEmail[email].orders++;
          if (!byEmail[email].lastOrder || new Date(o.created_at) > new Date(byEmail[email].lastOrder)) {
            byEmail[email].lastOrder = o.created_at;
            byEmail[email].lastOrderNumber = o.order_number;
          }
        });
        var list = Object.keys(byEmail).map(function(email) { return byEmail[email]; });
        list.sort(function(a, b) { return (b.orders - a.orders) || (new Date(b.lastOrder) - new Date(a.lastOrder)); });
        if (list.length === 0) {
          tbody.innerHTML = '<tr><td colspan="5">No customers yet (orders will appear here).</td></tr>';
          return;
        }
        tbody.innerHTML = list.map(function(c) {
          var last = c.lastOrder ? new Date(c.lastOrder).toLocaleDateString() : '—';
          return '<tr><td>' + (c.name || '—') + '</td><td>' + (c.email || '—') + '</td><td>' + (c.phone || '—') + '</td><td>' + c.orders + '</td><td>' + last + '</td></tr>';
        }).join('');
      }).catch(function(err) {
        tbody.innerHTML = '<tr><td colspan="5">Error loading customers</td></tr>';
        console.error(err);
      });
  }

  // ——— Test Supabase ———
  document.getElementById('btnTestSupabase').addEventListener('click', testSupabaseConnection);
  var btnCheckAdmin = document.getElementById('btnCheckAdminList');
  if (btnCheckAdmin) btnCheckAdmin.addEventListener('click', checkAdminList);
  var btnAlert = document.getElementById('btnTestSupabaseAlert');
  if (btnAlert) btnAlert.addEventListener('click', testSupabaseConnection);

  // ——— Login ———
  document.getElementById('loginForm').addEventListener('submit', function(e) {
    e.preventDefault();
    var email = document.getElementById('loginEmail').value.trim();
    var password = document.getElementById('loginPassword').value;
    var errEl = document.getElementById('loginError');
    errEl.classList.add('d-none');
    if (!supabase) {
      errEl.textContent = 'Set SUPABASE_URL and SUPABASE_ANON_KEY in admin/config.js';
      errEl.classList.remove('d-none');
      return;
    }
    supabase.auth.signInWithPassword({ email: email, password: password }).then(function(r) {
      if (r.error) {
        errEl.textContent = r.error.message || 'Sign in failed';
        errEl.classList.remove('d-none');
        return;
      }
      showApp();
    }).catch(function(e) {
      errEl.textContent = e.message || 'Sign in failed';
      errEl.classList.remove('d-none');
    });
  });

  document.getElementById('btnLogout').addEventListener('click', function() {
    if (supabase) supabase.auth.signOut();
    supabase = null;
    showLogin();
  });

  // ——— Init: check session then show app or login ———
  if (!config || !config.SUPABASE_URL || !config.SUPABASE_ANON_KEY) {
    document.getElementById('alertConfig').classList.remove('d-none');
    document.getElementById('adminApp').classList.remove('d-none');
    document.getElementById('loginView').classList.add('d-none');
    initSupabase();
    loadDashboard();
    loadProducts();
  } else {
    initSupabase();
    supabase.auth.getSession().then(function(r) {
      if (r.data && r.data.session) {
        showApp();
      } else {
        showLogin();
      }
    }).catch(function() {
      showLogin();
    });
  }
})();
