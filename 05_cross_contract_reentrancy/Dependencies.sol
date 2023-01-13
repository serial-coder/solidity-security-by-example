// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-smart-contract-security-by-example-05-cross-contract-reentrancy-30f29e2a01b9
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-05-cross-contract-reentrancy/

pragma solidity 0.8.17;

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
    function transferOwnership(address _newOwner) external;
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function mint(address _to, uint256 _value) external returns (bool success);
    function burnAccount(address _from) external returns (bool success);
}

contract MoonToken {
    uint256 private constant MAX_UINT256 = type(uint256).max;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    string public constant name = "MOON Token";
    string public constant symbol = "MOON";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not the owner");
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function transfer(address _to, uint256 _value)
        external
        returns (bool success)
    {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success) {
        uint256 allowance_ = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance_ >= _value);

        balances[_to] += _value;
        balances[_from] -= _value;

        if (allowance_ < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        return true;
    }

    function balanceOf(address _owner)
        external
        view
        returns (uint256 balance)
    {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value)
        external
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        return true;
    }

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    function mint(address _to, uint256 _value)
        external
        onlyOwner  // MoonVault must be the contract owner
        returns (bool success)
    {
        balances[_to] += _value;
        totalSupply += _value;
        return true;
    }

    function burnAccount(address _from)
        external
        onlyOwner  // MoonVault must be the contract owner
        returns (bool success)
    {
        uint256 amountToBurn = balances[_from];
        balances[_from] -= amountToBurn;
        totalSupply -= amountToBurn;
        return true;
    }
}