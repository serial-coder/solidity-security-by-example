// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-security-by-example-11-denial-of-service-with-induction-variable-overflow-9991299ac8e4
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-11-denial-of-service-with-induction-variable-overflow/

pragma solidity 0.6.12;

interface ISimpleAirdrop {
    function transferAirdrops(uint256 _amount, address[] calldata _receivers) external;
}

contract IssueSimulation {
    uint256 public constant MAX_RECEIVERS = 300;

    function simulateIssue(ISimpleAirdrop _simpleAirdrop, uint256 _amount) external {
        require(_amount > 0, "Amount must be more than 0");

        // Generate a mock-up set of 300 receivers
        address[] memory receivers = new address[](MAX_RECEIVERS);
        for (uint256 i = 0; i < MAX_RECEIVERS; i++) {
            receivers[i] = address(i + 1000);  // receiver addresses: [1000 - 1299]
        }

        _simpleAirdrop.transferAirdrops(_amount, receivers);
    }
}