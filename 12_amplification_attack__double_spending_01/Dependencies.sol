// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-security-by-example-12-amplification-attack-double-spending-1-990b2da52e6c
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-12-amplification-attack-double-spending-01/

pragma solidity 0.8.20;

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

interface IMoonToken {
    function buy(uint256 _amount) external payable;
    function sell(uint256 _amount) external;
    function transfer(address _to, uint256 _amount) external;
    function transferFrom(address _from, address _to, uint256 _value) external;
    function approve(address _spender, uint256 _value) external;
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function getEtherBalance() external view returns (uint256);
    function getUserBalance(address _user) external view returns (uint256);
}

contract MoonToken {
    mapping (address => uint256) private userBalances;
    mapping (address => mapping (address => uint256)) private allowed;

    uint256 private constant MAX_UINT256 = type(uint256).max;
    uint256 public constant TOKEN_PRICE = 1 ether;

    string public constant name = "Moon Token";
    string public constant symbol = "MOON";

    // The token is non-divisible
    // You can buy/sell/transfer 1, 2, 3, or 46 tokens but not 33.5
    uint8 public constant decimals = 0;

    function buy(uint256 _amount) external payable {
        require(
            msg.value == _amount * TOKEN_PRICE, 
            "Ether submitted and Token amount to buy mismatch"
        );

        userBalances[msg.sender] += _amount;
    }

    function sell(uint256 _amount) external {
        require(userBalances[msg.sender] >= _amount, "Insufficient balance");

        userBalances[msg.sender] -= _amount;

        (bool success, ) = msg.sender.call{value: _amount * TOKEN_PRICE}("");
        require(success, "Failed to send Ether");
    }

    function transfer(address _to, uint256 _amount) external {
        require(_to != address(0), "_to address is not valid");
        require(userBalances[msg.sender] >= _amount, "Insufficient balance");
        
        userBalances[msg.sender] -= _amount;
        userBalances[_to] += _amount;
    }

    function transferFrom(address _from, address _to, uint256 _value) external {
        uint256 allowance_ = allowed[_from][msg.sender];
        require(
            userBalances[_from] >= _value && allowance_ >= _value, 
            "Insufficient balance"
        );

        userBalances[_to] += _value;
        userBalances[_from] -= _value;

        if (allowance_ < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
    }

    function approve(address _spender, uint256 _value) external {
        allowed[msg.sender][_spender] = _value;
    }

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    function getEtherBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserBalance(address _user) external view returns (uint256) {
        return userBalances[_user];
    }
}