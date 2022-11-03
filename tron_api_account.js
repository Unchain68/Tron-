const TronWeb = require('tronweb')

//you don't have to use tron-api key while you are going to work on testnet
const tronWeb = new TronWeb({
    fullHost: 'https://api.shasta.trongrid.io',
    headers: { "TRON-PRO-API-KEY": '' },
    privateKey: ''
})

console.log(tronWeb.fromMnemonic('patch left empty genuine rain normal syrup yellow consider moon stock denial'));
