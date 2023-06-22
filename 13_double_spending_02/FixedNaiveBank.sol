// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-security-by-example-13-double-spending-2-609ba4402aca
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-13-double-spending-02/

pragma solidity 0.8.20;

// This contract still has a denial-of-service issue, but it is not the scope of 
// this example though. Therefore, please do not use this contract code in production
contract FixedNaiveBank {
    uint256 public constant INTEREST_RATE = 5;  // 5% interest

    struct Account {
        bool registered;  // FIX: Use the 'registered' attribute to keep track of every registered account
        uint256 balance;
    }

    mapping (address => Account) private userAccounts;
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

    function deposit() external payable {
        require(msg.value > 0, "Require some funds");
        
        // FIX: Use the 'registered' attribute to keep track of every registered account
        if (!userAccounts[msg.sender].registered) {
            // Register new user
            userAddresses.push(msg.sender);
            userAccounts[msg.sender].registered = true;
        }

        userAccounts[msg.sender].balance += msg.value;
    }

    function withdraw(uint256 _withdrawAmount) external {
        require(userAccounts[msg.sender].balance >= _withdrawAmount, "Insufficient balance");
        userAccounts[msg.sender].balance -= _withdrawAmount;

        (bool success, ) = msg.sender.call{value: _withdrawAmount}("");
        require(success, "Failed to send Ether");
    }

    // There is a denial-of-service issue on the applyInterest() function, 
    // but it is not the scope of this example though
    function applyInterest() external onlyOwner returns (uint256 minBankBalanceRequired_) {
        for (uint256 i = 0; i < userAddresses.length; i++) {
            address user = userAddresses[i];
            uint256 balance = userAccounts[user].balance;

            // Update user's compound interest
            userAccounts[user].balance = balance * (100 + INTEREST_RATE) / 100;

            // Calculate the minimum bank balance required to pay for each user
            minBankBalanceRequired_ += userAccounts[user].balance;
        }
    }

    function getBankBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) external view returns (uint256) {
        return userAccounts[_user].balance;
    }
}