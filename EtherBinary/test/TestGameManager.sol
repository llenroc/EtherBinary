pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/implementations/GameFactory.sol";
import "../contracts/logic/GameManager.sol";

contract TestGameManager {
    uint public initialBalance = 1 ether;

    function beforeAll () {
       gameManager = new GameManager(DeployedAddresses.GameFactory());
    }

    function testEnablePause() public {
        gameManager.setPaused(true);

        bool expected = true;
        Assert.equal(gameManager.isPaused(), expected, "Contract should be paused");
    }

    function testDisablePause() public {
        gameManager.setPaused(true);
        gameManager.setPaused(false);

        bool expected = false;
        Assert.equal(gameManager.isPaused(), expected, "Contract should not be paused");
    }

    function testSetGameFactory() public{
        address notExpected = gameManager.getCurrentFactory();
        
        gameManager.setPaused(true);
        gameManager.setGameFactory(new GameFactory());
        gameManager.setPaused(false);

        Assert.notEqual(gameManager.getCurrentFactory(), notExpected, "Returned address should not be empty");
    }


    function testCreateNewGame() public {
        address notExpected = address(0);
        address newGame = gameManager.createNewGame("XXBTZUSD","BTC/USD", "Bitcoin");

        Assert.notEqual(newGame, notExpected, "Returned address should not be empty");
    }

    // function testInitialBalance() public {
    //     GameFactory factory = GameFactory(DeployedAddresses.GameFactory());

    //     address notExpected = address(0);
    //     address deployedGameAddress = factory.createNewGame("XXBTZUSD","BTC/USD", "Bitcoin");

    //     Assert.notEqual(deployedGameAddress, notExpected, "Owner should have 10000 MetaCoin initially");
    // }

   

    



    // function testCreateNewGame() public {
    //     GameManager gameManager = new GameManager(DeployedAddresses.GameFactory());

    //     GameFactory factory = GameFactory(DeployedAddresses.GameFactory());

    //     address expected = gameManager.getCurrentFactory();
    //     address deployedGameAddress = factory.createNewGame("XXBTZUSD","BTC/USD", "Bitcoin");

    //     Assert.equal(deployedGameAddress, notExpected, "Returned address should not be empty");
    // }

    // function testSetGetResultsMinutes() public {
    //     GameFactory factory = GameFactory(DeployedAddresses.GameFactory());

    //     address notExpected = address(0);
    //     address deployedGameAddress = factory.createNewGame("XXBTZUSD","BTC/USD", "Bitcoin");

    //     Assert.notEqual(deployedGameAddress, notExpected, "Returned address should not be empty");
    // }



    // function testInitialBalanceWithNewMetaCoin() public {
    //     MetaCoin meta = new MetaCoin();

    //     uint expected = 10000;

    //     Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
    // }

}
