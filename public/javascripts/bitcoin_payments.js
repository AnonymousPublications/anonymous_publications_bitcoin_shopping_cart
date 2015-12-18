var valuesToSaveGlobal = ['address_first_name', 'address_last_name', 'address_country', 'address_address1', 'address_address2', 'address_apt', 'address_city', 'address_state', 'address_zip'];


$(document).ready(function() {
  initEventHandlers();
  onQtyChanged();
  
  initAddressFields();
});


function initAddressFields(){
  if ( $('#address_style_saved').is(':checked') ) {
    onAddressStyleSavedSelected('e');
  }
  else {
    onAddressStyleNewSelected('e');
  }
}


function initEventHandlers(){
  $('#address_style_saved').on("click", function(e){onAddressStyleSavedSelected(e)});
  $('#address_style_new').on("click",function(e){onAddressStyleNewSelected(e)});
  
  $('#toggle-discounts-btn').on("click",function(e){toggleDiscountCheckboxes(e)});
  $('#purchase-submit').on("click",function(e){ onBtnPurchaseSubmitClicked(valuesToSaveGlobal) });
  $('.submit').on("click",function(e){ onBtnPurchaseSubmitClicked(valuesToSaveGlobal) });
  $('#btnDeleteAddressInfo').on("click", function(e){ btnDeleteAddressValues(valuesToSaveGlobal) });
}

function btnDeleteAddressValues(valuesToDelete){
  if ( !doValuesExistInLocalCache(valuesToDelete) ){
    alert("Unencrypted address values have already deleted.  \nRefreshing or navigating away from the page will \nobscure the values from your end forever.  \n(Hopefully you hit print or copied to a txt file!)");
    return;
  }

  var msg = "Srsly Encrypt Address Info?\n";
  msg += "\n  Did you print/ save your address info so you can";
  msg += "\n  later confirm where you shipped your package to?";
  msg += "\n  You won't be able to check again so click cancel"
  msg += "\n  and print the page if you hanen't done so yet."
  var shouldDeleteAddressValues = confirm(msg);
  
  if (shouldDeleteAddressValues){
    deleteAddressValues(valuesToDelete);
  }
}

function onBtnPurchaseSubmitClicked(valuesToSave){
  deleteAddressValues(valuesToSave); // hurray for good measure!
  
  var addressSetToSave = $('#address_style_saved').prop("checked");
  
  if(!addressSetToSave)
    saveAddressValuesLocally(valuesToSave);
  
  //encrypt('hello', getkey(encryption_key));
}

function onShowPageLoad(values){
  var shouldRenderValues = doValuesExistInLocalCache(values);
  
  if (shouldRenderValues){
    populateAddressFields(values);
  }
  else{
    $('#btnDeleteAddressInfo').hide();
    $('.recommend-printing').hide();
  }
}

function onBtnCancelSaleClick(e){
  
}

// converts a string representing a number or a number
// into satoshi so discrete math can be performed digitally
// with 64bit integers
function convertToSatoshi(btcValue){
  return Number(btcValue) * 100000000;
}

function convertToBtc(satoshiValue){
  return satoshiValue / 100000000;
}

function calculateCartCost(){
  var qty = Number($('#qty').val());

  var price_per_book = convertToSatoshi($('#line_items_0_price_spoof').val());
  var product_amount = qty * price_per_book;
  
  var bitcoin_discount = convertToSatoshi($('#btc_discount').val());
  var total_bitcoin_discount = bitcoin_discount * qty;
  
  var price_after_fixed_discounts = product_amount + total_bitcoin_discount;
  
  var bulk_discount = calculate_bulk_discount(qty, price_after_fixed_discounts);
  
  var shipping_cost = convertToSatoshi($('#products_0_shipping_price_spoof').val());
  
  

  items = [];
  // pwtd
  items[0] = { name: "pwtd", price: price_per_book, qty: qty, price_extend: product_amount };
  // BTC discount
  items[1] = { name: "BTC Discount", price: bitcoin_discount, qty: 1, price_extend: bitcoin_discount * qty };
  
  // bulk discount
  items[2] = { name: "Bulk Discount", price: bulk_discount, qty: 1, price_extend: bulk_discount };
  
  var cart_amount = items[0]["price_extend"] + roundFour(items[1]["price_extend"]) + roundFour(items[2]["price_extend"]) + roundFour(shipping_cost);
  return cart_amount;
}


function calculate_bulk_discount(qty, product_amount_satashi){
  discount_percent = 0;
  switch(qty){
    case 1:
      discount_percent = 1.0 - 1.0;
      break;
    case 2:
    case 3:
    case 4:
    case 5:
    case 6:
      discount_percent = 1.0 - 0.95;
      break;
    case 0:
      discount_percent = 1.0 - 1.0;
      break;
    default:
      discount_percent = 1.0 - 0.55;
      break;
  }
  // discount_percent = discount_percent * 100;
  discount_amount = (discount_percent * product_amount_satashi);
  return -1 * discount_amount;
}

function roundFour(num){
  return Math.round(num/10000) * 10000;
}

function onQtyChanged(e){
  var cart_cost = calculateCartCost();
  
  var presented_sale_price = convertToBtc( cart_cost );
  $('#book-cost').html( presented_sale_price );
}

function onQtyKeyDown(e){
  setTimeout(function() {
		onQtyChanged();
	}, 10);
}


// Hide the address creation fields and show the address selection drop box
function onAddressStyleSavedSelected(e){
  $('#address_select_box').show();
  $('.address_create_field').hide();
}

// Hide the address selection box and show the address creation fields
function onAddressStyleNewSelected(e){
  $('#address_select_box').hide();
  $('.address_create_field').show();
}



// validite input boxes to recieve numbers only on keydown
function numbersOnly(e)
{
	var keynum;
	var keychar;
	var numcheck;
	
	if(window.event){
		keynum = e.keyCode;
	}
	else if(e.which){
		keynum = e.which;
	}
	keychar = String.fromCharCode(keynum);
	numcheck = /\D/  // /\d/;
	

	if (e.keyCode == 8 || e.keyCode == 9 || e.keyCode == 13 || e.keyCode == 27 || e.keyCode == 116){
		return true;
	}
	else if (e.keyCode >= 37 && e.keyCode <= 40){
		return true;
	}
	else if (e.keyCode >= 96 && e.keyCode <= 105){
		return true;
	}
	else if (e.keyCode == 190 || e.keyCode == 110){
		if (e.target.value.indexOf('.') != -1 ){
			return false;
		}
		else{
			return true;
		}
	}
	
	return !numcheck.test(keychar);
}



function toggle_discount_checkbox(e){
  var element = $(e.target).parent().children().first();
  
  var old_status = element.prop("checked");
  
  element.prop("checked", !old_status);
  return false;
}


function display_instruction_textarea_if_applicable(){
  // if any checkboxes on the form are checked,
  // and if the textarea is hidden
  // then roll down the instruction text area...
}

function toggleDiscountCheckboxes(event){
  var is_hidden = $(".discount-checkboxes").css("display") == "none";
  if (is_hidden){
    $(".discount-checkboxes").slideDown();
  }
  else{
    $(".discount-checkboxes").slideUp();
  }
}



function saveAddressValuesLocally(valuesToSave){
  var m_valuesToSave = valuesToSave.slice()
  m_valuesToSave.push("address_code_name");
  for (var i = 0; i < m_valuesToSave.length; i++){
    localStorage.setItem( m_valuesToSave[i] , $("#" + m_valuesToSave[i]).val() );
  }
}

// This function doesn't actually encrypt, it just deletes the unencrypted 
// form, the encrypted stuff was passed up to the web app after being 
// encrypted using RSA keys
function deleteAddressValues(valuesToDelete){
  for (var i = 0; i < valuesToDelete.length; i++){
    localStorage.setItem(valuesToDelete[i], "");
  }
}

function populateAddressFields(valuesToSave){
  if(theseArentTheDroidsWereLookingFor())
    return;
  
  var prefix = "address_";
  
  for (var i = 0; i < valuesToSave.length; i++){
    var label = valuesToSave[i].replace(prefix, "").replace("_"," ");
    var value = localStorage.getItem( valuesToSave[i] );
    var targetElement = $("#" + valuesToSave[i]);   // $('#address_code_name').html("<p> <b>address:</b>  The Address</p>")
    
    targetElement.html("<p> <span class='address-label'>" + label + ":</span>  " + value + "</p>");
  }
}

// ret false if we should run poaddress name matches address name
function theseArentTheDroidsWereLookingFor(){
  var codeName = $(".code_name_header div span");
  
  // check if codename is broken... if someone changes the /sales/show view they will break mah beautiful codew0rkz
  if (codeName.length == 0){
    alert("someone broke my code in bitcoin_payments!  If you see this in production that's seriously F'd up!  Tweet us with error code: #roflthunder666");
    alert("not kidding! srysly, there's no tests for this one cause our code is too creative for them!");
    alert("@anonlit");
    
    return true;
  }
  var codeNameChomped = chompCodeName(codeName.html());

  if (localStorage.getItem('address_code_name').trim() == codeNameChomped){
    return false;
  }
  return true;
}

function chompCodeName(stringToChomp){
  stringToChomp = stringToChomp.trim();
  var regexToFindEndingSymbol = /\W*\WR\d*$/;
  var positionOfEndingSymbol = stringToChomp.search(regexToFindEndingSymbol);
  var chompedString = stringToChomp.substring(0, positionOfEndingSymbol);
  return chompedString;
}


// if any of the valuesToCheck are present, returns true
// else returns false
function doValuesExistInLocalCache(valuesToCheck){
  for (var i = 0; i < valuesToCheck.length; i++){
    var localVal = localStorage.getItem(valuesToCheck[i]);
    if (localVal != "" && localVal != undefined){
      return true;
    }
  }
  return false;
}




function replaceSelectDropdownsWithHiddens(){
  var prefix = "address_";
  
  var vals = []
  // get original values
  for (var i = 0; i < valuesToSaveGlobal.length; i++){
    vals.push($('#'+valuesToSaveGlobal[i]).val());
  }
  // remove original inputs
  for (var i = 0; i < valuesToSaveGlobal.length; i++){
    $('#'+valuesToSaveGlobal[i]).remove();
  }
  // Install hidden inputs
  for (var i = 0; i < valuesToSaveGlobal.length; i++){
    var name = valuesToSaveGlobal[i].replace(prefix, "");
    name = "[" + name + "]";
    name = "address" + name;
    
    $("#address_code_name").after('<input type="hidden" id="' + valuesToSaveGlobal[i] + '" name="' + name + '" value="' + vals[i] + '"></input>');
  }
}


function encryptAddressValues(){
  valuesToEncrypt = valuesToSaveGlobal;
  for (var i = 0; i < valuesToEncrypt.length; i++){
    var targetElement = $("#" + valuesToEncrypt[i]);
    var clearText = targetElement.val();
    var cypher = encryptString(clearText);
    targetElement.val(cypher);
  }
}

function encryptString(clearText){
  return encryptSafe(clearText, encryption_key);
}


// sale/[:id]
// this function tells the rails app to look at blockchain.info and manually see if there are any new pmts on there
// if there are, then the page must reload
function checkIfNewPmtsFoundAndReload(){
  if (window.location.search == "?new_payments_found=true"){
    return;
  }
  
  $.ajaxSetup({ async: true });
  var request = $.ajax("/new_payments_found")
    .complete(function() {
      if (request.responseText == "true"){
        window.location = window.location.href + "?new_payments_found=true";
      }
    })
    .fail(function() { alert("Ajax request failed"); });
}


function discountField_keydown(e){
  if (e.keyCode == 13){
    submitDiscount();
  }
  
}

// sale/[:id]
// this function set handles the ajax queries for applying discounts to a sale

function submitDiscount(){
  // get discount code from text input
  discount_code = $("#discount-code-textbox").val();
  // sale_id is specified in haml...

  // return 1 if nothing is in the input box
  if (discount_code == "")
    return 1;

  // do ajax request with the discount_code in the params
  queryDiscountCode(discount_code, sale_id);
  
}


function queryDiscountCode(discount_code, sale_id) {
  $.ajaxSetup({ async: true });
  var request = $.ajax("/sales/apply_coupon_to_sale" + "?token=" + discount_code + "&sale_id=" + sale_id)
    .complete(function() { 
      if (request.responseText == "true"){
      alert("Coupon Confirmed, page will update"); 
      window.location = window.location.href;
      }
      else{
        alert(request.responseText + ".  That means it didn't work \nhmmm... \nmaybe a typo?  \nAlways feel free to msg us w/ bug reports, thanks!  <3");
      }
      
    })
    .fail(function() { alert("Ajax request failed trying to submit_discount"); })

  var response = request.response.body;
  return response;
}












