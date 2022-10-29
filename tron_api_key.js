// The latest version 3.2.6 of Tronweb can set API Key parameters through the setHeader method

//Example 2
const TronWeb = require('tronweb')

//you don't have to use tron-api key while you are going to work on testnet
const tronWeb = new TronWeb({
    fullHost: 'https://api.shasta.trongrid.io',
    headers: { "TRON-PRO-API-KEY": '' },
    privateKey: ''
})

let privateKey;
let publicKey;
let address_base58;
let address_hex;

tronWeb.createAccount().then(v => {
  //address 
  privateKey = v.privateKey;
  publicKey = v.publicKey;
  address_base58 = v.address.base58;
  address_hex = v.address.hex;

  address_base58 = v.address_base58;
  console.log(
    'privateKey: ' + privateKey + '\n' +
    'publicKey: ' + publicKey + '\n' +
    'address_base58: ' + address_base58 + '\n' +
    'address_hex: ' + address_hex
  )
});
