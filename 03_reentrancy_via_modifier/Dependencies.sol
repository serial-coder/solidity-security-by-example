// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//--------------------------------------------------------------------------//
// Copyright 2022 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//--------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-smart-contract-security-by-example-03-reentrancy-via-modifier-fba6b1d8ff81
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-03-reentrancy-via-modifier/

pragma solidity 0.8.13;

interface IAirdropReceiver {
    function canReceiveAirdrop() external returns (bool);
}