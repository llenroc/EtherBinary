var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "rose address blood aisle soul fold device service cinnamon island dial actress";

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
                return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/v3/58ee693c6a614003b268faac6f302ddc")
            },
            network_id: 4  // Rinkeby network id
        }
    }
};