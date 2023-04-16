// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-security-by-example-10-denial-of-service-with-gas-limit-346e87e2ef78
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-10-denial-of-service-with-gas-limit/

pragma solidity 0.8.19;

contract InsecureNaiveBank {
    uint256 public constant INTEREST_RATE = 5;  // 5% interest

    mapping (address => uint256) private userBalances;
    address[] private userAddresses;

    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not the owner");
        _;
    }

    function depositBankFunds() external payable onlyOwner {
        require(msg.value > 0, "Require some funds");
    }

    // There is a double spending issue on the depositFor() function, 
    // but it is not the scope of this example though
    function depositFor(address _user) external payable {
        require(_user != address(0), "Do not support a zero address");
        require(msg.value > 0, "Require some funds");

        // Register new user
        if (userBalances[_user] == 0) {
            userAddresses.push(_user);
        }

        userBalances[_user] += msg.value;
    }

    function withdraw(uint256 _withdrawAmount) external {
        require(userBalances[msg.sender] >= _withdrawAmount, "Insufficient balance");
        userBalances[msg.sender] -= _withdrawAmount;

        (bool success, ) = msg.sender.call{value: _withdrawAmount}("");
        require(success, "Failed to send Ether");
    }

    function applyInterest() external onlyOwner returns (uint256 minBankBalanceRequired_) {
        for (uint256 i = 0; i < userAddresses.length; i++) {
            address user = userAddresses[i];
            uint256 balance = userBalances[user];

            // Update user's compound interest
            userBalances[user] = balance * (100 + INTEREST_RATE) / 100;

            // Calculate the minimum bank balance required to pay for each user
            minBankBalanceRequired_ += userBalances[user];
        }
    }

    function getBankBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) external view returns (uint256) {
        return userBalances[_user];
    }

    function getUserLength() external view returns (uint256) {
        return userAddresses.length;
    }
}