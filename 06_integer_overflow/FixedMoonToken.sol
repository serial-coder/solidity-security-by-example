// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-smart-contract-security-by-example-06-integer-overflow-e1f444f3cc4
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-06-integer-overflow/

pragma solidity 0.6.12;

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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}

contract FixedMoonToken {
    using SafeMath for uint256;
    
    mapping (address => uint256) private userBalances;

    uint256 public constant TOKEN_PRICE = 1 ether;
    string public constant name = "Moon Token";
    string public constant symbol = "MOON";

    // The token is non-divisible
    // You can buy/sell 1, 2, 3, or 46 tokens but not 33.5
    uint8 public constant decimals = 0;

    function buy(uint256 _tokenToBuy) external payable {
        require(
            msg.value == _tokenToBuy.mul(TOKEN_PRICE),  // FIX: Apply SafeMath
            "Ether received and Token amount to buy mismatch"
        );

        userBalances[msg.sender] = userBalances[msg.sender].add(_tokenToBuy);  // FIX: Apply SafeMath
    }

    function sell(uint256 _tokenToSell) external {
        require(userBalances[msg.sender] >= _tokenToSell, "Insufficient balance");

        userBalances[msg.sender] = userBalances[msg.sender].sub(_tokenToSell);  // FIX: Apply SafeMath

        (bool success, ) = msg.sender.call{value: _tokenToSell.mul(TOKEN_PRICE)}("");  // FIX: Apply SafeMath
        require(success, "Failed to send Ether");
    }

    function getEtherBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) external view returns (uint256) {
        return userBalances[_user];
    }
}