var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "@Mymnemonic";

module.exports = {
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    },
    networks: {
        development: {
            host: "127.0.0.1",
            port: 8545,
            network_id: "*" // Match any network id
        },
        rinkeby: {
            provider: function() {
                return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/@ApiKey")
            },
            network_id: 4  // Rinkeby network id
        }
    }
};