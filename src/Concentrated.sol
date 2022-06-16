// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Context {
    address public user;

    ///@dev Usr -> Token -> Balance
    mapping(address => mapping(address => uint256)) public balanceOf;
}

contract Concentrated is Context {
    address public token0;
    address public token1;

    constructor() payable {}

    /// @dev our prices, where index = where the current price in
    uint256[5] public grid = [1, 2, 5, 9, 11];

    uint256 public currentIndex; // starts at 0 => price = 1

    uint256 public currentPrice;

    /// @notice Account -> Price -> Liquidity
    /// @dev Maps an account to amount of liquidity owned by the account
    mapping(address => mapping(uint256 => uint256)) public positions;

    /// @notice price => Liquidity
    /// @dev maps a price to liquidity
    mapping(uint256 => uint256) public ticks;

    /// @dev Token 0 -> Token 1
    function swap(uint256 amount, uint256 limitprice) public {
        // Get the current price.
        uint256 currentPrice = getCurrentPrice();

        // Get the liquidity at current price
        uint256 liquidity = getLiquidityAtPrices(currentPrice);

        // Get the new price
        uint256 nextPrice = getNextPrice(currentPrice);

        // Get the actual swap amounts
        (
            uint256 actualPrice,
            uint256 amountIn,
            uint256 amountOut
        ) = getSwapAmount(amount, currentPrice, nextPrice, liquidity);

        // Do the actual swap

        // set the current price to the actual price

        _setPrice(actualPrice);

        // Update the balances
        balanceOf[msg.sender][token0] -= amountIn;
        balanceOf[msg.sender][token1] += amountOut;
    }

    /// @dev for now use a state variable
    function getCurrentPrice() public view returns (uint256) {
        return grid[currentIndex];
    }

    /// @dev Lookup some data structure using currentPrice as its key and returns some liquidity amount
    function getLiquidityAtPrices(uint256 price)
        public
        view
        returns (uint256 liquidity)
    {
        return ticks[price];
    }

    /// @dev Lookup next higher price given a price
    function getNextPrice(uint256 price)
        public
        view
        returns (uint256 nextPrice)
    {
        nextPrice = grid[currentIndex + 1];
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
