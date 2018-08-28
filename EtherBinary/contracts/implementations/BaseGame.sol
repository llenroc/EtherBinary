pragma solidity ^0.4.22;

import "../implementations/Pausable.sol";
import "../interfaces/GameI.sol";
import "../libraries/strings.sol";
import "../../installed_contracts/zeppelin/contracts/math/SafeMath.sol";
import "../../installed_contracts/oraclize-api/contracts/usingOraclize.sol";

/** @title Contract that contains all the logic for a Game. */
contract BaseGame is usingOraclize, GameI, Pausable(false) {
    using SafeMath for uint256;
    using SafeMath for uint8;
    using strings for *;

    // Enums
    enum MatchStatus { Ready, BetsAllowed, BetsNotAllowed, Finished }

    // Structs
    struct Match { 
        uint pairInitialPrice;
        uint pairFinalPrice;
        uint startTime; 
        uint endTime; 
        uint totalPool;
        uint earningsByTicket;
        bool winnerOption; 
        mapping(address=>uint) playerTotalTickets;
        mapping(address=>bool) playerOption;
        mapping(address=>bool) playerEarningsWithdrawn;
        mapping(bool=>uint) optionTotalTickets;
        mapping(bool=>uint) optionTotalPool;
        bytes32 initalPriceQueryId;
        bytes32 betPeriodQueryId;
        bytes32 getFinalResultQueryId;
        MatchStatus status; 
    }
    
    // Variables
    string assetPair; 
    string assetPairAlias; 
    string description; 
    string resultsEndpoint;
    uint currentMatchId;
    uint8 betsDurationMinutes; 
    uint8 getResultsMinutes; 
    uint8 maxTicketsPerPlayer;
    uint ticketPrice;
    uint houseEdge;
    uint32 oraclizeGasLimit;
    uint[] matchesIds;

    // Mappings
    mapping(address=>uint[]) playerMatches;
    mapping(uint=>Match) matches;
    
    // Events
    event LogNewOraclizeQuery(uint indexed matchId, string description, uint timestamp);
    event LogEarningsWithdrawn(string assetPair, uint matchId, address indexed player, uint amount, uint timestamp);
    event LogMatchStarted(string assetPair, uint indexed matchId, uint startTime, uint initialPrice);
    event LogBettingPeriodEnd(string assetPair, uint indexed matchId, uint totalPool, uint timestamp);

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

    // Validates that the match status is "Ready".
    modifier whenMatchReady() {
        require(matches[currentMatchId].status == MatchStatus.Ready, "Match status must be 'Ready'!");
        _;
    }

    // Validates that the match status is "BetsAllowed".
    modifier whenBetsAllowed() {
        require(matches[currentMatchId].status == MatchStatus.BetsAllowed, "Match status must be 'BetsAllowed'!");
        _;
    }

        // Validates that the match status is "BetsNotAllowed".
    modifier whenBetsNotAllowed() {
        require(matches[currentMatchId].status == MatchStatus.BetsNotAllowed, "Match status must be 'BetsNotAllowed'!");
        _;
    }

    // Validates that the match status is "Finished".
    modifier whenMatchFinished() {
        require(matches[currentMatchId].status == MatchStatus.Finished, "Match status must be 'Finished'!");
        _;
    }

    // Validates that the calling address is the Oraclize.
    modifier fromOraclize {
        require(msg.sender == oraclize_cbAddress(), "Sender must be the Oraclize address!");
        _;
    }

    // Validates that the match status is "Finished".
    modifier resultEndpointWasSet() {
        require(bytes(resultsEndpoint).length > 0, "Results Endpoint must be set!");
        _;
    }

    // @dev Contract constructor.
    constructor () public payable
    {
    }
    
    /** @dev Sets the information of the asset pair and sets the oraclize endpoint.
    * @param _assetPair The assetPair of the game.
    * @param _assetPairAlias Alias of the assetPair used for display.
    * @param _description The description of the game used for display.
    */
    function setAssetPairInformation(string _assetPair, string _assetPairAlias, string _description) external fromOwner whenNotPaused {
        require(bytes(_assetPair).length > 0, "Asset pair cannot be an empty value!");
        require(bytes(_assetPairAlias).length > 0, "Asset pair alias cannot be an empty value!");
        require(bytes(_description).length > 0, "Description cannot be an empty value!");

        // WARNING: Just for development purposes, must be removed when deploying to production/testnet.
        // Setting development oraclize resolver.
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

        assetPair = _assetPair;
        assetPairAlias = _assetPairAlias;
        description = _description;
    
        setApiEndpoint();
    }

     // @dev Sets the endpoint to be called by the Oraclize.
    function setApiEndpoint() private fromOwner whenNotPaused {
        // Setting result endpoint.
        string memory endpointStart = "json(https://api.kraken.com/0/public/Ticker?pair=";
        string memory endpointResult = ").result.";
        string memory endpointLast = ".c.0";

        resultsEndpoint = endpointStart.toSlice().concat(
            assetPair.toSlice().concat(
                endpointResult.toSlice().concat(
                    assetPair.toSlice().concat(
                        endpointLast.toSlice()
                    ).toSlice()
                ).toSlice()
            ).toSlice()
        );
    }
    
    /** @dev Set game variables and start game.
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
    ) external fromOwner whenNotPaused resultEndpointWasSet {

        require(_betsDurationMinutes > 0, "Bets duration time cannot be zero!");
        require(_getResultsMinutes > 0, "Get results treshold cannot be zero!");
        require(_maxTicketsPerPlayer > 0, "Max tickets per player cannot be zero!");
        require(_ticketPrice > 0, "Ticket price cannot be zero!");
        require(_oraclizeGasLimit > 0, "Match status cannot be zero!");

        betsDurationMinutes = _betsDurationMinutes;
        getResultsMinutes = _getResultsMinutes;
        maxTicketsPerPlayer = _maxTicketsPerPlayer;
        ticketPrice = _ticketPrice;
        houseEdge = _houseEdge;
        oraclizeGasLimit = _oraclizeGasLimit;
        
        startNewMatch();
    }

    // @dev Initializes a new match and start it.
    function startNewMatch() private whenNotPaused {
        currentMatchId += 1;
        matches[currentMatchId].status = MatchStatus.Ready;
        matchesIds.push(currentMatchId);
        callStartGameOraclize();
    }

    /** @dev Returns the game relevant information.
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
    ) 
    {
        return (
            assetPair, 
            assetPairAlias, 
            description, 
            ticketPrice, 
            currentMatchId, 
            maxTicketsPerPlayer, 
            betsDurationMinutes, 
            getResultsMinutes
        );
    }

    /** 
    * @dev Payable function to buy tickets.
    * @param option Option to bet to.
    */
    function buyTickets(bool option) external payable  whenBetsAllowed whenNotPaused {
        uint userTickets = matches[currentMatchId].playerTotalTickets[msg.sender];

        require(msg.value >= ticketPrice, "Amount must be equal or greater than a single ticket price.");
        require(userTickets < maxTicketsPerPlayer, "User reached max amount of tickets per player allowed.");

        // Validating that the player hasn't bet to the rival contender.
        if (userTickets > 0) {
            require(matches[currentMatchId].playerOption[msg.sender] != !option, "User cannot buy ticket for both options!");
        }
        
        uint ticketsToBuy = msg.value.div(ticketPrice);

        // If the number of tickets that the user can buy is greater than maxTicketsPerPlayer then calculate and set the max number of tickets that this user has available.
        if ((ticketsToBuy.add(userTickets)) > maxTicketsPerPlayer) {
            ticketsToBuy = maxTicketsPerPlayer.sub(userTickets);
        }

        // Tickets to buy must be greater than zero.
        assert(ticketsToBuy > 0);

        // // Setting tickets.
        matches[currentMatchId].playerTotalTickets[msg.sender] += ticketsToBuy;
        matches[currentMatchId].optionTotalTickets[option] += ticketsToBuy;
        matches[currentMatchId].playerOption[msg.sender] = option;

        // // If user has residue transfer it back.
        uint residue = msg.value.sub(ticketsToBuy.mul(ticketPrice));
        if (residue > 0) {
            msg.sender.transfer(residue);
        }

        if (userTickets < 1) {
            playerMatches[msg.sender].push(currentMatchId);
        }

        emit LogTicketBought(
            assetPair,
            currentMatchId,
            msg.sender, 
            ticketsToBuy,
            matches[currentMatchId].playerTotalTickets[msg.sender], 
            option, 
            matches[currentMatchId].optionTotalTickets[option],
            now
        );
    }
 
    // @dev Sends oraclize query to start the match. 
    function callStartGameOraclize() private whenMatchReady whenNotPaused {
        if (oraclize_getPrice("URL", oraclizeGasLimit) > address(this).balance) {
            emit LogNewOraclizeQuery(currentMatchId, "Oraclize query was not sent due to insufficient balance, please add some ETH to cover for the query fee.", now);
        } else {
            emit LogNewOraclizeQuery(currentMatchId, "Oraclize query was sent to get pair initial price, waiting for answer...", now);
            matches[currentMatchId].initalPriceQueryId = oraclize_query("URL", resultsEndpoint, oraclizeGasLimit);
        }
    }

    // @dev Sends oraclize query to get timestamp and start betting period the match. 
    function callStartBetPeriodOraclize() private whenBetsAllowed whenNotPaused {
        if (oraclize_getPrice("WolframAlpha", oraclizeGasLimit) > address(this).balance) {
            emit LogNewOraclizeQuery(currentMatchId, "Oraclize query was not sent due to insufficient balance, please add some ETH to cover for the query fee.", now);
        } else {
            emit LogNewOraclizeQuery(currentMatchId, "Oraclize query was sent to start betting period, waiting for answer...", now);
            matches[currentMatchId].betPeriodQueryId = oraclize_query(betsDurationMinutes * 60, "WolframAlpha", "timestamp", oraclizeGasLimit);
        }
    }

    // @dev Sends oraclize query to get match final price and end match.
    function callResultsOraclize() private whenBetsNotAllowed whenNotPaused {
        if (oraclize_getPrice("URL", oraclizeGasLimit) > address(this).balance) {
            emit LogNewOraclizeQuery(currentMatchId, "Oraclize query was not sent due to insufficient balance, please add some ETH to cover for the query fee.", now);
        } else {
            emit LogNewOraclizeQuery(currentMatchId, "Oraclize query was sent to get pair final price, waiting for answer...", now);
            matches[currentMatchId].getFinalResultQueryId = oraclize_query(getResultsMinutes * 60, "URL", resultsEndpoint, oraclizeGasLimit);
        }
    }

    /** 
    * @dev Oraclize callback action
    * @param queryId Id of the executed query.
    * @param result Callback result.
    */
    function __callback(bytes32 queryId, string result) public fromOraclize whenNotPaused {
        if (matches[currentMatchId].initalPriceQueryId == queryId) {
            // Set match initial information.
            matches[currentMatchId].pairInitialPrice = parseInt(result, 5);
            matches[currentMatchId].status = MatchStatus.BetsAllowed;
            matches[currentMatchId].startTime = now;

            emit LogMatchStarted(assetPair, currentMatchId, matches[currentMatchId].startTime, matches[currentMatchId].pairInitialPrice);
            callStartBetPeriodOraclize();
        }
        else if (matches[currentMatchId].betPeriodQueryId == queryId) {
            // Validates that there are at least one ticket per option, otherwise restart betting period.
            if (matches[currentMatchId].optionTotalTickets[true] < 1 || matches[currentMatchId].optionTotalTickets[false] < 1) {
                callStartBetPeriodOraclize();
            }
            else {
                matches[currentMatchId].status = MatchStatus.BetsNotAllowed;

                // Calculating total pools.
                matches[currentMatchId].optionTotalPool[false] = matches[currentMatchId].optionTotalTickets[false].mul(ticketPrice);
                matches[currentMatchId].optionTotalPool[true] = matches[currentMatchId].optionTotalTickets[true].mul(ticketPrice);
                matches[currentMatchId].totalPool = matches[currentMatchId].optionTotalPool[false].add(matches[currentMatchId].optionTotalPool[true]);
                
                emit LogBettingPeriodEnd(assetPair, currentMatchId, matches[currentMatchId].totalPool, now);
                callResultsOraclize();
            }
        }
        else if (matches[currentMatchId].getFinalResultQueryId == queryId) {
            determineWinner(parseInt(result, 5));
        }
    }

    /** 
    * @dev Determines the winner based on the Oraclize query.
    * @param finalPrice Pair final price.
    */
    function determineWinner(uint finalPrice) private whenBetsNotAllowed whenNotPaused {
        // Set match status "Finished" and set finalPrice.
        matches[currentMatchId].status = MatchStatus.Finished;
        matches[currentMatchId].pairFinalPrice = finalPrice;

        // Set winner based on oraclize result.
        matches[currentMatchId].winnerOption = (matches[currentMatchId].pairFinalPrice > matches[currentMatchId].pairInitialPrice);
       
        CalculateEarnings(matches[currentMatchId].winnerOption);
    }

    // @dev Function called by a player to withdraw all pending withdrawals.
    function withdrawEarnings() external whenNotPaused {
        uint totalEarnings;         
        uint[] memory playerPastMatchesIds = playerMatches[msg.sender];

        require(playerPastMatchesIds.length > 0, "Player not found!");

        for (uint8 i = 0; i < playerPastMatchesIds.length; i++) {
            Match storage pastMatch = matches[playerPastMatchesIds[i]];

            if (pastMatch.status == MatchStatus.Finished){
                if (pastMatch.playerEarningsWithdrawn[msg.sender] == false) {
                    if (pastMatch.playerOption[msg.sender] == pastMatch.winnerOption) {
                        uint earnings = pastMatch.earningsByTicket.mul(pastMatch.playerTotalTickets[msg.sender]);
                        uint ticketsBought = ticketPrice.mul(pastMatch.playerTotalTickets[msg.sender]);

                        uint totalAmount = earnings.add(ticketsBought);
                        totalEarnings += totalAmount;

                        require(totalEarnings > 0, "Amount to withdraw must be greater than zero.");

                        matches[playerPastMatchesIds[i]].playerEarningsWithdrawn[msg.sender] = true;
                        msg.sender.transfer(totalEarnings);
                        
                        emit LogEarningsWithdrawn(assetPair, playerPastMatchesIds[i], msg.sender, totalEarnings, now);
                    }
                } 
            }
        }
    }

    // @dev Set the winner, calculates the earnings and starts a new match.
    function CalculateEarnings(bool winnerOption) private whenNotPaused whenMatchFinished {
        // Calculate total earnings and earnings by ticket.
        uint houseEarnings = houseEdge.mul(matches[currentMatchId].optionTotalTickets[!winnerOption]); 
        uint finalEarnings = matches[currentMatchId].optionTotalPool[!winnerOption].sub(houseEarnings);
        uint ticketEarnings = finalEarnings.div(matches[currentMatchId].optionTotalTickets[winnerOption]);
        
        matches[currentMatchId].earningsByTicket = ticketEarnings;

        // Emit match finished event.
        emit LogMatchFinished(
            assetPair,
            currentMatchId, 
            matches[currentMatchId].startTime, 
            now, 
            matches[currentMatchId].pairInitialPrice, 
            matches[currentMatchId].pairFinalPrice, 
            matches[currentMatchId].earningsByTicket,
            matches[currentMatchId].winnerOption
        );

        startNewMatch();
    }

    // @dev  Allows the owner to destruct the contrat in case of an emergency.
    function destructContract() external fromOwner {
        selfdestruct(this.getOwner());
    }   
}