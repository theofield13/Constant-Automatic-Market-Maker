// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Contract {
    constructor() payable {}

    /// @notice Account -> Price -> Liquidity
    /// @dev Maps an account to amount of liquidity owned by the account
    mapping(address = > uint) public positions;

    mapping(uint => uint) public ticks;

    function allocate(
        address to,
        uint256 amount,
        uint256 price
    ) public {
        positions[to][price] += amount;
        ticks[price] += amount;
    }

    function swap(
        uint256 direction,
        uint256 amount,
        uint256 price
    ) public {}

    function remove(uint256 amount, uint256 price) public {
        positions[msg.sender][price] -= amount;
        ticks[price] -= amount; // This will revert if tick[price]
    }
}
