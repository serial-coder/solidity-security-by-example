// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-security-by-example-11-denial-of-service-with-induction-variable-overflow-9991299ac8e4
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-11-denial-of-service-with-induction-variable-overflow/

pragma solidity 0.6.12;

// This contract still has integer overflow and denial-of-service issues, but they are not 
// the scope of this example though. Therefore, please do not use this contract code in production
contract FixedSimpleAirdrop {
    address public immutable launcher;

    constructor(address _launcher) public payable {
        require(_launcher != address(0), "Launcher cannot be a zero address");
        require(msg.value >= 1 ether, "Require at least 1 Ether");
        launcher = _launcher;
    }

    modifier onlyLauncher() {
        require(launcher == msg.sender, "You are not the launcher");
        _;
    }
    
    function transferAirdrops(uint256 _amount, address[] calldata _receivers) external onlyLauncher {
        require(_amount > 0, "Amount must be more than 0");
        require(_receivers.length > 0, "Require at least 1 receiver");
        require(
            getBalance() >= _amount *  _receivers.length,  // Integer overflow issue (not the scope of this example)
            "Insufficient Ether balance to transfer"
        );

        // Transfer airdrops to all receivers
        for (uint256 i = 0; i < _receivers.length; i++) {  // FIX: Apply uint256 for the variable "i"
            (bool success, ) = _receivers[i].call{value: _amount}("");  // Denial-of-service issue (not the scope of this example)
            require(success, "Failed to send Ether");
        }
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}