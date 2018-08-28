pragma solidity ^0.4.22;

import "../interfaces/OwnedI.sol";

contract Owned is OwnedI {
    address internal ownerAddress;

    modifier fromOwner() {
        require(msg.sender == ownerAddress);
        _;
    }

    constructor() public{
        ownerAddress = msg.sender;
    }

    function setOwner (address newOwner) external fromOwner returns(bool success) {
        require(newOwner != ownerAddress);
        require(newOwner != address(0));

        ownerAddress = newOwner;
        emit LogOwnerSet(ownerAddress, newOwner);
        return true;
    }

    function getOwner() external view returns(address owner) {
        return ownerAddress;		
    }
}