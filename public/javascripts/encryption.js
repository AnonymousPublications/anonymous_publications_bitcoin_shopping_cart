// IN:   string
// OUT:  named hash of [keyid, pktype, pubkey]
function getkey(armouredPublicKey) {
  var pu=new getPublicKey(armouredPublicKey);
  if(pu.vers == -1) return false;

  var vers = pu.vers;
  var user = pu.user;
  var keyid = pu.keyid;

  var pubkey = pu.pkey.replace(/\n/g,'');
  var pktype = pu.type;
  
  return {keyid: pu.keyid, pktype: pu.type, pubkey: pubkey};
}


// IN:  cleartext, {keyid, pktype='RSA', pubkey}
// OUT: false or armored gpg blob
function encrypt(clearText, gpgData) {
  var keyid = gpgData['keyid'];
  var pktype = gpgData['pktype'];
  var pubkey = gpgData['pubkey'];
  
  if(keyid.length != 16) {
    alert('Invalid Key Id');
    return false;
  }

  keytyp = -1;
  if(pktype == 'ELGAMAL') keytyp = 1;
  if(pktype == 'RSA')     keytyp = 0;
  if(keytyp == -1) {
    alert('Unsupported Key Type');
    return false;
  }

  var text=clearText+'\r\n';
  return doEncrypt(keyid, keytyp, pubkey, text);
}


function encryptSafe(clearText, pgpEncryptionKey) {
  var publicKey = openpgp.key.readArmored(pgpEncryptionKey);
  var cypher = openpgp.encryptMessage(publicKey.keys, clearText);
  return cypher;
}

