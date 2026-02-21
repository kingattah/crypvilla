(function() {
  var script = document.createElement('script');
  script.src = 'https://js.paystack.co/v1/inline.js';
  script.defer = true;
  document.head.appendChild(script);

  function generateReference() {
    return 'CRV-' + Date.now() + '-' + Math.random().toString(36).slice(2, 10);
  }

  window.CrypvillaPaystack = {
    isReady: function() {
      return typeof window.PaystackPop !== 'undefined';
    },
    pay: function(options, onSuccess, onFailure, onClose) {
      var config = window.CRYPVILLA_CONFIG;
      if (!config || !config.PAYSTACK_PUBLIC_KEY) {
        if (onFailure) onFailure(new Error('Paystack not configured'));
        return;
      }
      var ref = options.transaction_reference || generateReference();
      var amountNaira = Number(options.amount);
      var amountKobo = Math.round(amountNaira * 100);

      var handler = window.PaystackPop.setup({
        key: config.PAYSTACK_PUBLIC_KEY,
        email: options.email || '',
        amount: amountKobo,
        currency: 'NGN',
        ref: ref,
        callback: function(response) {
          if (response && response.reference) {
            if (onSuccess) onSuccess({ reference: response.reference, response: response });
          } else {
            if (onFailure) onFailure(response || new Error('Payment failed'));
          }
        },
        onClose: function() {
          if (onClose) onClose();
        }
      });

      try {
        if (handler && handler.openIframe) handler.openIframe();
        else if (onFailure) onFailure(new Error('Paystack checkout failed to init'));
      } catch (e) {
        if (onFailure) onFailure(e);
      }
    }
  };
})();
