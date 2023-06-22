// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-security-by-example-13-double-spending-2-609ba4402aca
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-13-double-spending-02/

pragma solidity 0.8.20;

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

    function deposit() external payable {
        require(msg.value > 0, "Require some funds");

        // Register new user
        if (userBalances[msg.sender] == 0) {
            userAddresses.push(msg.sender);
        }

        userBalances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _withdrawAmount) external {
        require(userBalances[msg.sender] >= _withdrawAmount, "Insufficient balance");
        userBalances[msg.sender] -= _withdrawAmount;

        (bool success, ) = msg.sender.call{value: _withdrawAmount}("");
        require(success, "Failed to send Ether");
    }

    // There is a denial-of-service issue on the applyInterest() function, 
    // but it is not the scope of this example though
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
}