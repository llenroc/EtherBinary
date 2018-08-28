var stringLib = artifacts.require("./libraries/strings.sol");
var BaseGame = artifacts.require("./implementations/BaseGame.sol");
var GameFactory = artifacts.require("./implementations/GameFactory.sol");
var GameManager = artifacts.require("./logic/GameManager.sol");
var GamesConfiguration = "";

module.exports = function(deployer, network, accounts) {
    if (network == "development") {
        GamesConfiguration = require("./configurations/dev_config.json");
    } 
    else {
        GamesConfiguration = require("./configurations/prod_config.json");
    }

    var factory, manager;

    deployer.then(function() {
        return deployer.deploy(GameFactory)
    }).then(function(instance) {
        factory = instance;
        return deployer.deploy(GameManager, instance.address);
    }).then(function(instance) {
        manager = instance;
        
        //Setting the GameManager to be the owner of the GameFactory contract.
        factory.setOwner(manager.address);
        
        // Creating each game contract based on the configuration files.
        GamesConfiguration.Games.forEach(game => {
            return  manager.createNewGame(game.AssetPair, game.AssetPairAlias, game.Description, { from: '0xD3df5c9e4897A55a3568C05752AaBAf0777b048c', gas:6721975, value: 1000000000000000000 });
        });
    });
};