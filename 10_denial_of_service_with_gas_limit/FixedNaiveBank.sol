// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-security-by-example-10-denial-of-service-with-gas-limit-346e87e2ef78
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-10-denial-of-service-with-gas-limit/

pragma solidity 0.8.19;

// This contract demonstrates a simple batch processing for calculating users' compound interests.
// It is just a proof of concept of the batch processing only. 

// The contract still has a double spending issue via the depositFor() function, 
// but it is not the scope of this example though. Even an approach to calculating 
// the interests is still insecure.

// For this reason, please do not use this contract code in your production

contract FixedNaiveBank {
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

    // FIX: This function demonstrates a simple batch processing for calculating users' compound interests
    // It is just a proof of concept of the batch processing only and should not be used in production
    function batchApplyInterest(uint256 _beginUserID, uint256 _endUserID) 
        external onlyOwner returns (uint256 minBankBalanceRequiredThisBatch_) 
    {
        require(_beginUserID < userAddresses.length, "_beginUserID is out of range");
        require(_endUserID >= _beginUserID, "_endUserID must be more than or equal to _beginUserID");

        if (_endUserID >= userAddresses.length) {
            _endUserID = userAddresses.length - 1;
        }
        
        for (uint256 i = _beginUserID; i <= _endUserID; i++) {
            address user = userAddresses[i];
            uint256 balance = userBalances[user];

            // Update user's compound interest
            userBalances[user] = balance * (100 + INTEREST_RATE) / 100;

            // Calculate the minimum bank balance required (for this batch) to pay for each user
            minBankBalanceRequiredThisBatch_ += userBalances[user];
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