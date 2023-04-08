// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-security-by-example-09-denial-of-service-with-revert-814f55b61e02
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-09-denial-of-service-with-revert/

pragma solidity 0.8.19;

import "./Dependencies.sol";

// Preventive solution
//   -> Let users withdraw their Ethers instead of sending the Ethers to them (pull model)

contract FixedWinnerTakesItAll is ReentrancyGuard {
    address public currentleader;
    uint256 public lastDepositedAmount;

    mapping (address => uint256) public prevLeaderRefunds;  // FIX: For recording available refunds of all previous leaders

    uint256 public currentLeaderReward;
    uint256 public nextLeaderReward;

    bool public rewardClaimed;
    uint256 public immutable challengeEnd;

    constructor(uint256 _challengePeriod) payable {
        require(msg.value == 10 ether, "Require an initial 10 Ethers reward");

        currentleader = address(0);
        lastDepositedAmount = msg.value;
        currentLeaderReward = 0;
        nextLeaderReward = msg.value;
        rewardClaimed = false;
        challengeEnd = block.timestamp + _challengePeriod;
    }

    function claimLeader() external payable noReentrant {
        require(block.timestamp < challengeEnd, "Challenge is finished");
        require(msg.sender != currentleader, "You are the current leader");
        require(msg.value > lastDepositedAmount, "You must pay more than the current leader");

        if (currentleader == address(0)) {  // First claimer (no need to refund the initial reward)
            // Assign the new leader
            currentleader = msg.sender;
            lastDepositedAmount = msg.value;

            currentLeaderReward = nextLeaderReward;  // Accrue the reward
            nextLeaderReward += lastDepositedAmount / 10;  // Deduct 10% from the last deposited amount for the next leader
        }
        else {  // Next claimers
            // Refund the previous leader with 90% of his deposit
            uint256 refundAmount = lastDepositedAmount * 9 / 10;

            // Assign the new leader
            address prevLeader = currentleader;
            currentleader = msg.sender;
            lastDepositedAmount = msg.value;

            currentLeaderReward = nextLeaderReward;  // Accrue the reward
            nextLeaderReward += lastDepositedAmount / 10;  // Deduct 10% from the last deposited amount for the next leader

            // FIX: Record a refund for the previous leader
            prevLeaderRefunds[prevLeader] += refundAmount;
        }
    }

    // FIX: For previous leaders to claim their refunds
    function claimRefund() external noReentrant {
        uint256 refundAmount = prevLeaderRefunds[msg.sender];
        require(refundAmount != 0, "You have no refund");

        prevLeaderRefunds[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: refundAmount}("");
        require(success, "Failed to send Ether");
    }

    // For the winner to claim principal and reward
    function claimPrincipalAndReward() external noReentrant {
        require(block.timestamp >= challengeEnd, "Challenge is not finished yet");
        require(msg.sender == currentleader, "You are not the winner");
        require(!rewardClaimed, "Reward was claimed");

        rewardClaimed = true;

        // Transfer principal + reward to the winner
        uint256 amount = lastDepositedAmount + currentLeaderReward;

        (bool success, ) = currentleader.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    function getEtherBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function isChallengeEnd() external view returns (bool) {
        return block.timestamp >= challengeEnd;
    }
}