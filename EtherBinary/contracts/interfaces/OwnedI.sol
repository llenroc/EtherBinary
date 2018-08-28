pragma solidity ^0.4.22;

/** @title Interface that establishes the functions that a Owned contract must implement. */
interface OwnedI {
    /**
     * @dev Event emitted when a new owner has been set.
     * @param previousOwner The previous owner, who happened to effect the change.
     * @param newOwner The new, and current, owner the contract.
     */
    event LogOwnerSet(address indexed previousOwner, address indexed newOwner);

    /** @dev Sets a new owner for this contract.
     * @param newOwner The new owner of the contract
     * @return success Whether the action was successful.
     */
    function setOwner(address newOwner) external returns(bool success);

    /**
     * @return owner The owner of this contract.
     */
    function getOwner() external view returns(address owner);
}