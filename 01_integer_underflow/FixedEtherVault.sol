// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-smart-contract-security-by-example-01-integer-underflow-c1147c2e507b
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-01-integer-underflow/

pragma solidity 0.6.12;

import "./Dependencies.sol";

// Simplified SafeMath
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }
}

contract FixedEtherVault is ReentrancyGuard {
    using SafeMath for uint256;

    mapping (address => uint256) private userBalances;

    function deposit() external payable {
        userBalances[msg.sender] = userBalances[msg.sender].add(msg.value);  // FIX: Apply SafeMath
    }

    function withdraw(uint256 _amount) external noReentrant {
        uint256 balance = getUserBalance(msg.sender);
        require(balance.sub(_amount) >= 0, "Insufficient balance");  // FIX: Apply SafeMath

        userBalances[msg.sender] = userBalances[msg.sender].sub(_amount);  // FIX: Apply SafeMath
        
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    function getEtherBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) public view returns (uint256) {
        return userBalances[_user];
    }
}