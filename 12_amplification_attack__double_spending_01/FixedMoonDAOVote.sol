// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-security-by-example-12-amplification-attack-double-spending-1-990b2da52e6c
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-12-amplification-attack-double-spending-01/

pragma solidity 0.8.20;

import "./Dependencies.sol";

contract FixedMoonDAOVote is ReentrancyGuard {
    IMoonToken public immutable moonToken;
    uint256 public immutable voteDeadline;

    // User Vote 
    struct UserVote {
        uint256 candidateID;
        uint256 voteAmount;
        bool completed;
        bool moonWithdrawn; // FIX: Tracking the MOON token's withdrawal status
    }
    mapping (address => UserVote) private userVotes;

    // CEO Candidate
    struct CEOCandidate {
        string name;
        uint256 totalVoteAmount;
    }
    CEOCandidate[] private candidates;

    constructor(IMoonToken _moonToken, uint256 _voteDeadline) {
        moonToken = _moonToken;
        voteDeadline = _voteDeadline;

        // Candidate #0: Bob
        candidates.push(
            CEOCandidate({name: "Bob", totalVoteAmount: 0})
        );

        // Candidate #1: John
        candidates.push(
            CEOCandidate({name: "John", totalVoteAmount: 0})
        );

        // Candidate #2: Eve
        candidates.push(
            CEOCandidate({name: "Eve", totalVoteAmount: 0})
        );
    }

    function vote(uint256 _candidateID) external noReentrant {
        require(block.timestamp < voteDeadline, "Vote is finished");
        require(!userVotes[msg.sender].completed, "You have already voted");
        require(_candidateID < candidates.length, "Invalid candidate id");

        uint256 voteAmount = moonToken.getUserBalance(msg.sender);
        require(voteAmount > 0, "You have no privilege to vote");

        // FIX: Transfer the MOON tokens to lock in this contract 
        //      until the voting period is completed
        moonToken.transferFrom(msg.sender, address(this), voteAmount);

        userVotes[msg.sender] = UserVote({
            candidateID: _candidateID,
            voteAmount: voteAmount,
            completed: true,
            moonWithdrawn: false // FIX: Tracking the MOON token's withdrawal status
        });

        candidates[_candidateID].totalVoteAmount += voteAmount;
    }

    // FIX: Voters can withdraw MOON tokens after the voting period ends
    function withdrawMoonTokens() external noReentrant {
        require(block.timestamp >= voteDeadline, "Vote is not finished yet");
        require(userVotes[msg.sender].completed, "You did not make the vote");
        require(!userVotes[msg.sender].moonWithdrawn, "You have no MOON tokens to withdraw");

        // Mark that the MOON tokens are withdrawn
        userVotes[msg.sender].moonWithdrawn = true;

        // Transfer the MOON tokens back to the voter
        moonToken.transfer(msg.sender, userVotes[msg.sender].voteAmount);
    }

    function getTotalCandidates() external view returns (uint256) {
        return candidates.length;
    }

    function getUserVote(address _user) external view returns (UserVote memory) {
        return userVotes[_user];
    }

    function getCandidate(uint256 _candidateID) external view returns (CEOCandidate memory) {
        require(_candidateID < candidates.length, "Invalid candidate id");
        return candidates[_candidateID];
    }
}