//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title Simple contract demo receive function
contract Receiver {
    mapping(address => uint256) public userDepositAmount;

    /// @dev deposit fund by calling function
    function deposit() external payable {
        userDepositAmount[msg.sender] += msg.value;
    }

    /// @dev deposit fund by transfering ETH directly
    receive() external payable {
        userDepositAmount[msg.sender] += msg.value;
    }
}
