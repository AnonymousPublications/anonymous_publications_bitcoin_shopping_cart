// /articles/encrypting_emails
// 
function displayOnly(classToDisplay){
  var allObjects = [];
  
  var linuxObjects = [].slice.call(document.getElementsByClassName('linux'));
  var windowsObjects = [].slice.call(document.getElementsByClassName('windows'));
  var macObjects = [].slice.call(document.getElementsByClassName('mac'));
  var osIndepenentObjects = [].slice.call(document.getElementsByClassName('os-independent'));
  
  allObjects = allObjects.concat(linuxObjects, windowsObjects, macObjects, osIndepenentObjects);
  
  // Hide all the OS specific objects
  for (var i = 0; i < allObjects.length; i++){
    var o = allObjects[i];
    o.style.display = "none";
  }

  // Show the specific OS the user selected
  var classToDisplayObjects = [].slice.call(document.getElementsByClassName(classToDisplay));
  for (var i = 0; i < classToDisplayObjects.length; i++){
    var o = classToDisplayObjects[i];
    o.style.display = "block";
  }
  
  // Change the indent parameters so the selected object is where it belongs
  var maybeDontIndent = [].slice.call(document.getElementsByClassName('maybe-dont-indent'))[0];
  maybeDontIndent.style.margin = "0";
  
}

// /articles/encrypting_emails
//
function displayOsClicked(classToDisplay){
  displayOnly(classToDisplay);
  
  // change the drop down to indicate the OS name selected
  $('.os-label').html(classToDisplay);
}



// checks the platform and returns either 'linux', 'windows', or 'mac' (or 'unknown')
function getOsType(){
  var OSName="unknown";
  if (navigator.appVersion.indexOf("Win")!=-1) OSName="windows";
  if (navigator.appVersion.indexOf("Mac")!=-1) OSName="mac";
  if (navigator.appVersion.indexOf("X11")!=-1) OSName="linux";  // bug...
  if (navigator.appVersion.indexOf("Linux")!=-1) OSName="linux";
  
  return OSName;
}


