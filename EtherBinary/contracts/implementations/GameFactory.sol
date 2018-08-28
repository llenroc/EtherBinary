pragma solidity ^0.4.22;

import "../interfaces/GameFactoryI.sol";
import "../implementations/Pausable.sol";
import "../implementations/BaseGame.sol";

/** @title Factory used to create games. */
contract GameFactory is Pausable(false), GameFactoryI {
    // Variables
    uint8 public betsDurationMinutes; 
    uint8 public getResultsMinutes; 
    uint8 public maxTicketsPerPlayer;
    uint public ticketPrice;
    uint public houseEdge;
    uint32 public oraclizeGasLimit;

    // @dev Contract constructor.
    constructor () public
    {
        // Setting inital values.
        betsDurationMinutes = 1;
        getResultsMinutes = 1;
        maxTicketsPerPlayer = 5;
        ticketPrice = 100000000000000000; // 0.01 ETH
        houseEdge = 20000000000000000; // 0.002 ETH per ticket that lost the match.
        oraclizeGasLimit = 500000;
    }
    
    /** 
    * @dev Function used to create a new game based on the provided parameters.
    * @param assetPair The assetPair of the game.
    * @param assetPairAlias Alias of the assetPair used for display.
    * @param description The description of the game to be desplayed.
    * @return The address of the deployed game.
    */
    function createNewGame (
        string assetPair, 
        string assetPairAlias, 
        string description
    ) external payable fromOwner whenNotPaused returns (address) 
    {
        BaseGame newGame = (new BaseGame).value(msg.value)();
        BaseGame(newGame).setAssetPairInformation(assetPair, assetPairAlias, description);
        setGameVariables(address(newGame));

        return address(newGame);
    }

    /** 
    * @dev Set inital variables for a deployed game.
    * @param gameAddress Address of the game to set.
    */
    function setGameVariables (address gameAddress) private fromOwner whenNotPaused {
        BaseGame(gameAddress).setGameVariablesAndStart(
            betsDurationMinutes,
            getResultsMinutes,
            maxTicketsPerPlayer,
            ticketPrice,
            houseEdge,
            oraclizeGasLimit
        );
    }

    // @dev  Allows the owner to destruct the contrat in case of an emergency.
    function destructContract() external fromOwner {
        selfdestruct(this.getOwner());
    } 

     /** 
    * @dev Sets bets duration minutes.
    * @param newBetsDurationMinutes  Specifies the time in minutes of the duration of the betting period.
    */
    function setBetsDurationMinutes(uint8 newBetsDurationMinutes) external fromOwner whenPaused {
        betsDurationMinutes = newBetsDurationMinutes;
    }

    /** 
    * @dev Sets results duration minutes.
    * @param newGetResultsMinutes Specifies the time in minutes to get the match result after the betting period.
    */
    function setGetResultsMinutes(uint8 newGetResultsMinutes) external fromOwner whenPaused {
        getResultsMinutes = newGetResultsMinutes;
    }

    /** 
    * @dev Sets bets max tickets per player.
    * @param newMaxTicketsPerPlayer Max number of tickets that a player can buy.
    */
    function setMaxTicketsPerPlayer(uint8 newMaxTicketsPerPlayer) external fromOwner whenPaused {
        maxTicketsPerPlayer = newMaxTicketsPerPlayer;
    }

    /** 
    * @dev Sets tickets price.
    * @param newTicketPrice The price of a single ticket.
    */
    function setTicketPrice(uint newTicketPrice) external fromOwner whenPaused {
        ticketPrice = newTicketPrice;
    }

    /** 
    * @dev Sets house edge.
    * @param newHouseEdge House profit per ticket. 
    */
    function setHouseEdge(uint newHouseEdge) external fromOwner whenPaused {
        houseEdge = newHouseEdge;
    }

    /** 
    * @dev Sets gas limit for Oraclize calls.
    * @param newOraclizeGasLimit Gas amount to be used by the Oracle calls.
    */
    function setOraclizeGas(uint32 newOraclizeGasLimit) external fromOwner whenPaused {
        oraclizeGasLimit = newOraclizeGasLimit;
    }
}