pragma solidity ^0.4.22;

/** @title Interface that establishes the functions that a Game Factory contract must implement. */
interface GameFactoryI {

    /** 
    * @dev Function used to create a new game based on the provided parameters.
    * @param assetPair The assetPair of the game.
    * @param assetPairAlias Alias of the assetPair used for display.
    * @param description The description of the game to be desplayed.
    * @return The address of the deployed game.
    */
    function createNewGame(string assetPair, string assetPairAlias, string description) external payable returns (address);

    // @dev  Allows the owner to destruct the contrat in case of an emergency.
    function destructContract() external;

    /** 
    * @dev Sets bets duration minutes.
    * @param newBetsDurationMinutes  Specifies the time in minutes of the duration of the betting period.
    */
    function setBetsDurationMinutes(uint8 newBetsDurationMinutes) external;

    /** 
    * @dev Sets results duration minutes.
    * @param newGetResultsMinutes Specifies the time in minutes to get the match result after the betting period.
    */
    function setGetResultsMinutes(uint8 newGetResultsMinutes) external;

   /** 
    * @dev Sets bets max tickets per player.
    * @param newMaxTicketsPerPlayer Max number of tickets that a player can buy.
    */
    function setMaxTicketsPerPlayer(uint8 newMaxTicketsPerPlayer) external;

   /** 
    * @dev Sets tickets price.
    * @param newTicketPrice The price of a single ticket.
    */
    function setTicketPrice(uint newTicketPrice) external;

   /** 
    * @dev Sets house edge.
    * @param newHouseEdge House profit per ticket. 
    */
    function setHouseEdge(uint newHouseEdge) external;

   /** 
    * @dev Sets gas limit for Oraclize calls.
    * @param newOraclizeGasLimit Gas amount to be used by the Oracle calls.
    */
    function setOraclizeGas(uint32 newOraclizeGasLimit) external;
}