pragma solidity ^0.4.22;

/** @title Interface that establishes the functions that a Game contract must implement. */
interface GameI {

    /** 
    * @dev Event emitted when a new match has started.
    * @param assetPair The assetPair of the game.
    * @param matchId Id of the started match.
    * @param startTime The time in which the game started.
    * @param initialPrice The inital price of the asset.
    */
    event LogMatchStarted(string assetPair, uint indexed matchId, uint startTime, uint initialPrice);

    /** 
    * @dev Event emitted when a match betting period has finished.
    * @param assetPair The assetPair of the game.
    * @param matchId Id of the match.
    * @param totalPool Match total pool.
    * @param timestamp The time in which the event occured.
    */
    event LogBettingPeriodEnd(string assetPair, uint indexed matchId, uint totalPool, uint timestamp);

    /** 
    * @dev Event emitted when a ticket has been bought.
    * @param assetPair The assetPair of the game.
    * @param matchId Id of the match.
    * @param player The player who bought the ticket.
    * @param ticketsBought The amount of tickets bought in this transaction.
    * @param playerTotalTickets Total amount of tickets for this match.
    * @param option Option the player bet to.
    * @param optionTotalTickets Total pool of the option the player bet to.
    * @param timestamp The time in which the event occured.
    */
    event LogTicketBought(
        string assetPair, 
        uint indexed matchId, 
        address indexed player, 
        uint ticketsBought,
        uint playerTotalTickets, 
        bool option, 
        uint optionTotalTickets,
        uint timestamp
    );

   /** 
    * @dev Event emitted when a match has finished.
    * @param assetPair The assetPair of the game.
    * @param matchId Id of the match that has finished.
    * @param startTime The start time of the match.
    * @param endTime The end time of the match.
    * @param initialPrice Initial price of the asset.
    * @param endPrice End price of the asset.
    * @param earningsByTicket Amount of ether won by ticket.
    * @param winnerOption Option that winned the match.
    */
    event LogMatchFinished(
        string assetPair, 
        uint indexed matchId, 
        uint startTime, 
        uint endTime, 
        uint initialPrice, 
        uint endPrice, 
        uint earningsByTicket, 
        bool winnerOption
    );

    /** 
    * @dev Event emitted when user withdraw earnings.
    * @param assetPair The assetPair of the game.
    * @param matchId Id of the associated match.
    * @param player The player who withdraw earnings.
    * @param amount The amount withdrawn.
    * @param timestamp The time in which the event occured.
    */
    event LogEarningsWithdrawn(string assetPair, uint matchId, address indexed player, uint amount, uint timestamp);
    
    /** 
    * @dev Sets the information of the asset pair and sets the oraclize endpoint.
    * @param _assetPair The assetPair of the game.
    * @param _assetPairAlias Alias of the assetPair used for display.
    * @param _description The description of the game used for display.
    */
    function setAssetPairInformation(string _assetPair, string _assetPairAlias, string _description) external;

    /** 
    * @dev Set game variables and start game.
    * @param _betsDurationMinutes Specifies the time in minutes of the duration of the betting period.
    * @param _getResultsMinutes Specifies the time in minutes to get the match result after the betting period.
    * @param _maxTicketsPerPlayer Max number of tickets that a player can buy.
    * @param _ticketPrice The price of a single ticket.
    * @param _houseEdge House profit per ticket. 
    * @param _oraclizeGasLimit Gas amount to be used by the Oracle calls.
    */
    function setGameVariablesAndStart(
        uint8 _betsDurationMinutes, 
        uint8 _getResultsMinutes,
        uint8 _maxTicketsPerPlayer,
        uint _ticketPrice, 
        uint _houseEdge,
        uint32 _oraclizeGasLimit
    ) external;

    /** 
    * @dev Returns the game relevant information. 
    * @return _assetPair The assetPair of the game.
    * @return _assetPairAlias  Alias of the assetPair used for display.
    * @return _description The description of the game used for display.
    * @return _ticketPrice The price of a single ticket.
    * @return _currentMatchId Id of the current running match. 
    * @return _maxTicketsPerPlayer Max number of tickets that a player can buy.
    * @return _betsDurationMinutes Specifies the time in minutes of the duration of the betting period.
    * @return _getResultsMinutes  Specifies the time in minutes to get the match result after the betting period.
    */
    function getGameInfo() external view returns (
        string  _assetPair, 
        string  _assetPairAlias, 
        string  _description, 
        uint  _ticketPrice, 
        uint  _currentMatchId,
        uint8  _maxTicketsPerPlayer,
        uint8 _betsDurationMinutes,
        uint8 _getResultsMinutes
    );

    /** 
    * @dev Payable function to buy tickets.
    * @param option Option to bet to.
    */
    function buyTickets(bool option) external payable;

    // @dev Function called by a player to withdraw all pending withdrawals.
    function withdrawEarnings() external;

    // @dev  Allows the owner to destruct the contrat in case of an emergency.
    function destructContract() external;
}