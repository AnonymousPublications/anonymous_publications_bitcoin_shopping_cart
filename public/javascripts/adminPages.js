

// admin_pages/discounts

// this function was thrown together quickly just to make 99% off coupons work for the beta test
function genCoupon(discount_id, usage_limit, token){
  discount_param = "discount_id=" + discount_id;
  usage_param = "&usage_limit=" + usage_limit;
  
  token_param = "";
  if (token != null && token != ""){
    token_param = "&token=" + token;
  }
  
  
  $.ajaxSetup({ async: true });
  var request = $.ajax("/coupons/gen_coupon" + "?" + discount_param + usage_param + token_param)
                   .complete(function() { 
                     alert(request.responseText); 
                     window.location = window.location.href; 
                   })
                   .fail(function() { alert("Ajax request failed trying to submit_discount"); })
  
  // window.location = window.location.href;
}






