pragma solidity ^0.4.22;

import "../implementations/Pausable.sol";
import "../interfaces/GameI.sol";
import "../interfaces/GameFactoryI.sol";
import "../../installed_contracts/zeppelin/contracts/math/SafeMath.sol";

/** @title Game manager contract that serves as a registry. */
contract GameManager is Pausable(false) {
    using SafeMath for uint256;

    // Variables
    address public currentGameFactory;
    address[] public oldGameFactories;
    string[] deployedAssets;

    // Mappings
    mapping(string=>address) currentAssetContract;
    mapping(string=>address[]) oldAssetContracts;
    mapping(address=>address[]) playerGames;

    /**
    * @dev Contract constructor.
    * @param gameFactoryAddress Address of the game factory.
    */
    constructor (address gameFactoryAddress) public
    {
        currentGameFactory = gameFactoryAddress;
    }

    /**
    * @dev Returns the number of deployed games.
    * @return Amount of current games.
    */
    function getDeployedAssetsCount() external view returns (uint) {
        return deployedAssets.length;
    }

    /**
    * @dev Returns the information of a game located at an specific index.
    * @param index Index of the game to look for.
    * @return Asset pair of the game.
    * @return Address of the game's smart contract.
    */
    function getDeployedAssetContractAt(uint8 index) external view returns (string, address) {
        return (deployedAssets[index], currentAssetContract[deployedAssets[index]]);
    }

    /** 
    * @dev Function used to create a new game based on the provided parameters.
    * @param assetPair The assetPair of the game.
    * @param assetPairAlias Alias of the assetPair used for display.
    * @param description The description of the game to be desplayed.
    */
    function createNewGame(string assetPair, string assetPairAlias, string description) public payable fromOwner whenNotPaused returns (address) 
    {
        if (currentAssetContract[assetPair] != address(0)) {
            // Saving old contract.
            oldAssetContracts[assetPair].push(currentAssetContract[assetPair]);
        }
        else {
            deployedAssets.push(assetPair);
        }

        // Creating new contract for this asset and setting current variable.
        currentAssetContract[assetPair] = GameFactoryI(currentGameFactory).createNewGame.value(msg.value)(
            assetPair, 
            assetPairAlias, 
            description
        );
    }

    /**
    * @dev Function used to register a new game factory.
    * @param newGameFactoryAddress Address of the new game factory.
    */
    function setGameFactory(address newGameFactoryAddress) public fromOwner whenPaused
    {
        require(newGameFactoryAddress != currentGameFactory, "New game factory address must be different than current address.");

        oldGameFactories.push(currentGameFactory);
        currentGameFactory = newGameFactoryAddress;
    }

    /**
    * @dev Function used to return the current game factory.
    * @return Address of the current game factory.
    */
    function getCurrentFactory() public view returns (address)
    {
        return currentGameFactory;
    }
}