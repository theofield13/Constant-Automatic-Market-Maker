// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Context {
    address public user;

    ///@dev Usr -> Token -> Balance
    mapping(address => mapping(address => uint256)) public balanceOf;
}

contract Concentrated {
    constructor() payable {}

    /// @notice Account -> Price -> Liquidity
    /// @dev Maps an account to amount of liquidity owned by the account
    mapping(address => mapping(uint256 => uint256)) public positions;

    mapping(uint256 => uint256) public ticks;

    function swap(uint256 amount, uint256 limitprice) public {
        // Get the current price.
        uint256 currentPrice = getCurrentPrice();
    }

    // ---To Do ---//

    function allocate(
        address to,
        uint256 amount,
        uint256 price
    ) public {
        positions[msg.sender][price] += amount;
        ticks[price] += amount;
    }

    function remove(uint256 amount, uint256 price) public {
        positions[msg.sender][price] -= amount;
        ticks[price] -= amount; // This will revert if tick[price]
    }
}
