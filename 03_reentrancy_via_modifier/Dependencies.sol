// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//--------------------------------------------------------------------------//
// Copyright 2022 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//--------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: (coming soon)
//  - On serial-coder.com: (coming soon)

pragma solidity 0.8.13;

interface IAirdropReceiver {
    function canReceiveAirdrop() external returns (bool);
}