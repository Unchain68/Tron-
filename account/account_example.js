const TronWeb = require('tronweb')

//you don't have to use tron-api key while you are going to work on testnet
const tronWeb = new TronWeb({
    fullHost: 'https://api.shasta.trongrid.io',
    headers: { "TRON-PRO-API-KEY": '' },
    privateKey: ''
})

//Mnemonic class
function Mnemonic(phrase,path,locale) {
    this.phrase = phrase;
    this.path = path;
    this.locale = locale;
}  

//random key box class
function KeyBox(mnemonic,privateKey,publicKey,address) {
    this.mnemonic = new Mnemonic(mnemonic.phrase,mnemonic.path,mnemonic.locale);
    this.privateKey = privateKey;
    this.publicKey = publicKey;
    this.address = address;
}

const account = tronWeb.createRandom({path: "m/44'/195'/0'/0/0", extraEntropy: '', locale: 'en'});
const keyBox =new KeyBox(account.mnemonic,account.privateKey,account.publicKey,account.address);
console.log(keyBox);
