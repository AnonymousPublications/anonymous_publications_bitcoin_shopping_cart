
function nBlank_onKeyDown(s, e) {
  if( e.keyCode == 13 )
    addDesiredBlanks()
  else if( e.keyCode == 38 )
    incrementBlanks();
  else if ( e.keyCode == 40 )
    decrementBlanks();
}

function nBlank_onClick() {
  addDesiredBlanks();
}

function addDesiredBlanks() {
  var nBlanks = $('#nBlanks').val();
  setBlanks(nBlanks);
}




// Add blank logic

function incrementBlanks() {
  var nBlanks = getNBlanks();
  
  if (nBlanks < 29)
    setBlanks(nBlanks+1);
}

function decrementBlanks() {
  var nBlanks = getNBlanks();
  
  if (nBlanks > 0)
    setBlanks(nBlanks-1);
}

function setBlanks(nBlanks) {
  nBlanks = Number(nBlanks);
  if (nBlanks >= 30) {
    alert("can't add more than 29 blanks at a time");
    $("#nBlanks").focus();
    $("#nBlanks").select();
    return;
  }
  
  removeBlanks();
  insertBlanks(nBlanks);
  
  var sheets = $('.labels').children('.sheet');
  
  sheets.each(function(i) {
    
    var currentSheet = $(this);
    var nextSheet = $(sheets[i+1]);
    
    // any address divs after the first 30 are overflow and must be moved to the next sheet
    var addressesToMove = getOverflowInSheet(currentSheet);
    if (addressesToMove.length > 0 && nextSheet.length == 0) {
      nextSheet = $( makeNewSheet() );
    }
    
    moveAddressesToBeginningOfSheet(addressesToMove, currentSheet, nextSheet);
  });
  
  $('#nBlanks').val(getNBlanks());
}

function insertBlanks(nBlanks) {
  sheet = $('.labels').children('.sheet').first();
  
  clony = $('.hiddenLabel');
  //clony.removeClass('hiddenLabel');
  
  for (var i = 0; i < nBlanks; i++) {
    sheet.prepend("<div class='label ablank'>" + clony.html() + "</div>")
  }
}

function removeBlanks() {
  $(".ablank").remove();
}


// sheets = $('.labels').children('.sheet');
// s = [ sheets[0].children[0] ];
// insertAddressesIntoBeginningOfSheet($(sheets[0]), s);
// 
function moveAddressesToBeginningOfSheet(addressesToMove, startingSheet, endingSheet) {
  insertAddressesIntoBeginningOfSheet(endingSheet, addressesToMove);
  deleteLastNAddressesFromFirstSheet(startingSheet, addressesToMove.length);
}

function insertAddressesIntoBeginningOfSheet(sheet, addressesToMove) {
  for (var i = 0; i < addressesToMove.length; i++) {
    var address = $(addressesToMove[i]);
    sheet.prepend("<div class='label'>" + address.html() + "</div>")
  }
  
}

// deleteLastNAddressesFromFirstSheet($(sheets[0]), 1);
function deleteLastNAddressesFromFirstSheet(sheet, nToDelete) {
  for (var i = 0; i < nToDelete; i++) {
    var child = sheet.children().last();
    child.remove();
  }
}


// Returns an array of the divs that are in excess of 30 on the sheet
function getOverflowInSheet(sheet) {
  var elements = sheet.children();
  var remainder = elements.length - 30;
  
  if (remainder <= 0)
    return [];
  
  var array = [];
  
  elements.each(function(i) {
    var element = $(this);
    if (i >= 30)
      array[i-30] = element;
  });
  
  
  return array;
}

function makeNewSheet() {
  // Now we seem to have filled up the last sheet and we must create a new last sheet...
  $('.labels').append("<div class='sheet-header'></div>");
  $('.labels').append("<div class='sheet'></div>");
  
  return $('.labels').children('.sheet').last();
}

function getNBlanks() {
  return $(".ablank").length;
}

// End Add blank logic



