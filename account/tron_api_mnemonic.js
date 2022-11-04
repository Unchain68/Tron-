const TronWeb = require('tronweb')

//you don't have to use tron-api key while you are going to work on testnet
const tronWeb = new TronWeb({
    fullHost: 'https://api.shasta.trongrid.io',
    headers: { "TRON-PRO-API-KEY": '' },
    privateKey: ''
})

/* 
explaination of what is derivation?
m/44'/195'/0'/0/1
44 — is a convention; nothing to read into here.
195 — coin_type — 195 indicates the Tron network. The list of “registered coin types” can be found here.
0 — account — intended to represent different types of wallet users. 
    For example, a business may have one branch of accounts for an accounting department and another for a sales team. 
    It’s a zero-based index.
0 — change — mostly Bitcoin’s cup of tea. Typically remains 0 for Ethereum addresses.
1 — address_index — finally, the index of the account you’re using. 
    This is also a zero-based index, so index 0 is the first available account. 
    If you have ten accounts, the last’s derivation path is m/44'/195'/0'/0/9.
*/

//from mnemonic string
console.log(tronWeb.fromMnemonic('patch left empty genuine rain normal syrup yellow consider moon stock denial'));

//create Random without Mnemonic
console.log(tronWeb.createRandom({path: "m/44'/195'/0'/0/0", extraEntropy: '', locale: 'en'}));