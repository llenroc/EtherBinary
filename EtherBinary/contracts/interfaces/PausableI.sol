pragma solidity ^0.4.22;

/** @title Interface that establishes the functions that a Pausable contract must implement. */
interface PausableI {
    /**
     * @dev Event emitted when a new paused state has been set.
     * @param sender The account that ran the action.
     * @param newPausedState The new, and current, paused state of the contract.
     */
    event LogPausedSet(address indexed sender, bool indexed newPausedState);

    /** @dev Sets the new paused state for this contract.
     * @param newState The new desired "paused" state of the contract.
     * @return success Whether the action was successful.
     */
    function setPaused(bool newState) external returns(bool success);

    /**
     * @return Whether the contract is indeed paused.
     */
    function isPaused() external view returns(bool isIndeed);
}