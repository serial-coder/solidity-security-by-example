// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-smart-contract-security-by-example-05-cross-contract-reentrancy-30f29e2a01b9
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-05-cross-contract-reentrancy/

pragma solidity 0.8.17;

import "./Dependencies.sol";

// InsecureMoonVault must be the contract owner of the MoonToken
contract InsecureMoonVault is ReentrancyGuard {
    IMoonToken public immutable moonToken;

    constructor(IMoonToken _moonToken) {
        moonToken = _moonToken;
    }

    function deposit() external payable noReentrant {  // Apply the noReentrant modifier
        bool success = moonToken.mint(msg.sender, msg.value);
        require(success, "Failed to mint token");
    }

    function withdrawAll() external noReentrant {  // Apply the noReentrant modifier
        uint256 balance = getUserBalance(msg.sender);
        require(balance > 0, "Insufficient balance");

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Failed to send Ether");

        success = moonToken.burnAccount(msg.sender);
        require(success, "Failed to burn token");
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) public view returns (uint256) {
        return moonToken.balanceOf(_user);
    }
}