



// purchases/new
// autoFills the form for purchases/new address and all that
function autoFillForm(){
  $("#user_email").val("test@gmail.com");
  $("#user_email_confirmation").val("test@gmail.com");
  
  $("#address_code_name").val("My House");
  $("#address_first_name").val("Johnny");
  $("#address_last_name").val("Depp");
  $("#address_country").val("us");
  $("#address_address1").val("3579 Forest Grove Avenue");
  $("#address_address2").val("Lodging Wayham");
  $("#address_apt").val("1011");
  $("#address_city").val("Bullshitivile");
  $("#address_state").val("DC");
  $("#address_zip").val("11111");
}

// sale/[:id]
function deleteCurrentUsersBtcPmt(){
  var sale_id = getIdFromPathName();
  $.ajaxSetup({ async: false });
  var request = $.ajax("/delete_current_users_btc_pmt" + "?sale_id=" + sale_id).fail(function() { alert("Ajax request failed"); })
  
  window.location = window.location.href
}





// sale/[:id]
function triggerAjaxOfNewPmtsFound(){
  if (window.location.search != ""){
    alert("There's something in the search part of the url, we'll delete it and you try again");
    window.location.search = "";
    return 1;
  }
  // use api to set next request to be a bitcoin_payment found
  $.ajaxSetup({ async: false });
  var request = $.ajax("/test_funcs/trigger_bitcoin_payment_found_on_next_request").fail(function() { alert("Ajax request failed"); })
  
  checkIfNewPmtsFoundAndReload();
}


function getIdFromPathName(){
  var path = window.location.pathname;
  var id = path.substring("/sale/".length + 1);
  
  return Number(id);
}



















