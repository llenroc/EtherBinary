pragma solidity ^0.4.22;

import "./Owned.sol";
import "../interfaces/PausableI.sol";

/** @title Contract that contains all the logic for a Pausable contract. */
contract Pausable is Owned, PausableI {
    bool internal paused;

    modifier whenPaused(){
        require(paused, "");
        _;
    }

    modifier whenNotPaused(){
        require(!paused, "");
        _;
    }

    constructor(bool initialState) public {
        paused = initialState;
    }

    function setPaused(bool newState) external fromOwner returns(bool success) {
        require(paused != newState, "");
        paused = newState;
        emit LogPausedSet(msg.sender, newState);

        return true;
    }

    function isPaused() external view returns(bool isIndeed) {
        return paused;
    }
}