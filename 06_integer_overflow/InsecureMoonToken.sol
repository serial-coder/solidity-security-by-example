// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-smart-contract-security-by-example-06-integer-overflow-e1f444f3cc4
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-06-integer-overflow/

pragma solidity 0.6.12;

contract InsecureMoonToken {
    mapping (address => uint256) private userBalances;

    uint256 public constant TOKEN_PRICE = 1 ether;
    string public constant name = "Moon Token";
    string public constant symbol = "MOON";

    // The token is non-divisible
    // You can buy/sell 1, 2, 3, or 46 tokens but not 33.5
    uint8 public constant decimals = 0;

    function buy(uint256 _tokenToBuy) external payable {
        require(
            msg.value == _tokenToBuy * TOKEN_PRICE, 
            "Ether received and Token amount to buy mismatch"
        );

        userBalances[msg.sender] += _tokenToBuy;
    }

    function sell(uint256 _tokenToSell) external {
        require(userBalances[msg.sender] >= _tokenToSell, "Insufficient balance");

        userBalances[msg.sender] -= _tokenToSell;

        (bool success, ) = msg.sender.call{value: _tokenToSell * TOKEN_PRICE}("");
        require(success, "Failed to send Ether");
    }

    function getEtherBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) external view returns (uint256) {
        return userBalances[_user];
    }
}