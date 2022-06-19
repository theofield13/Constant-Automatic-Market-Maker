// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Context {
    address public user;

    address public token0;
    address public token1;

    ///@dev Usr -> Token -> Balance
    mapping(address => mapping(address => uint256)) public balanceOf;

    function setToken(address token0_, address token1_) public {
        token0 = token0_;
        token1 = token1_;
    }

    function setBalance(
        address user,
        address token,
        uint256 amount
    ) public {
        balanceOf[user][token] = amount;
    }
}

contract Concentrated is Context {
    constructor() payable {}

    /// @dev our prices, where index = where the current price in
    uint256[5] public grid = [1, 4, 9, 16, 25];

    uint256[5] public sqrtGrid = [1, 2, 3, 4, 5];

    uint256 public currentIndex; // starts at 0 => price = 1

    uint256 public currentPrice;

    /// @notice Account -> Price -> Liquidity
    /// @dev Maps an account to amount of liquidity owned by the account
    mapping(address => mapping(uint256 => uint256)) public positions;

    /// @notice price => Liquidity
    /// @dev maps a price to liquidity
    mapping(uint256 => uint256) public ticks;

    /// @dev Token 0 -> Token 1
    function swap(uint256 amount, uint256 limitprice)
        public
        returns (
            uint256 price,
            uint256 amountIn,
            uint256 amountOut
        )
    {
        // Get the current price.
        uint256 currentSqrtPrice = getCurrentSqrtPrice();

        // Get the liquidity at current price
        uint256 liquidity = getLiquidityAtSqrtPrice(currentSqrtPrice);

        // Get the new price
        uint256 nextPrice = getNextSqrtPrice(currentSqrtPrice);

        // Get the actual swap amounts
        (price, amountIn, amountOut) = getSwapAmounts(
            amount,
            currentSqrtPrice,
            nextPrice,
            liquidity
        );

        // Do the actual swap

        // set the current price to the actual price

        _setPrice(price);

        // Update the balances
        balanceOf[msg.sender][token0] -= amountIn;
        balanceOf[msg.sender][token1] += amountOut;
    }

    error setPriceError();

    function _setPrice(uint256 desiredPrice) public returns (bool success) {
        unchecked {
            uint256 gridlength = grid.length;
            for (uint256 i; i != gridlength; ++i) {
                uint256 priceOnGrid = grid[i];

                if (desiredPrice == priceOnGrid) {
                    currentIndex = i;
                    success = true;
                    break;
                }
            }
        }
        if (!success) revert setPriceError();
    }

    /// @dev for now use a state variable
    function getCurrentSqrtPrice() public view returns (uint256) {
        return sqrtGrid[currentIndex];
    }

    /// @dev Lookup some data structure using currentPrice as its key and returns some liquidity amount
    function getLiquidityAtSqrtPrice(uint256 price)
        public
        view
        returns (uint256 liquidity)
    {
        return ticks[sqrtPrice];
    }

    /// @dev Lookup next higher price given a price
    function getNextPrice(uint256 price)
        public
        view
        returns (uint256 nextPrice)
    {
        nextPrice = grid[currentIndex + 1];
    }

    function getSwapAmounts(
        uint256 swapAmount,
        uint256 currentPrice,
        uint256 nextPrice,
        uint256 liquidity
    )
        public
        view
        returns (
            uint256 price,
            uint256 amountIn,
            uint256 amountOut
        )
    {
        amountIn = swapAmount;

        uint256 deltaSqrtPrice = getChangeInPriceGivenX(amountIn, liquidity);

        amountOut = getChangeInYGivenPrice(deltaSqrtPrice, liquidity);

        if (deltaSqrtPrice > (nextPrice - currentPrice)) price = nextPrice;
        else price = currentPrice + deltaSqrtPrice;
    }

    /// @dev Δx = Δ(1/sqrt(Price)) * L
    ///      Δx = Δ(1/sqrt(PriceNext)) - sqrt(PriceCurrent)) * L
    ///      Δx / L = 1 / (√P_1 - √P_0)
    ///      Δp = L / Δx
    function getChangeInPriceGivenX(uint256 deltaX, uint256 liquidity)
        public
        view
        returns (uint256 deltaSqrtPrice)
    {
        deltaSqrtPrice = (liquidity * 1e18) / deltaX; // Unit Math: 1e18 = 1e18 * 1e18 / 1e18
    }

    /// @dev Δy = Δ(sqrt(Price)) * L
    function getChangeInYGivenPrice(uint256 deltaSqrtPrice, uint256 liquidity)
        public
        view
        returns (uint256 deltaY)
    {
        deltaY = (deltaSqrtPrice * liquidity) / 1e18; //Unint math: 1e18 = 1e18 * 1e18 / 1e18
    }

    // ---To Do ---//
    /// @dev L = sqrt(xy) - sqrt(k)
    /// Price = y / x
    /// L = sqrt(x * p * x)
    /// L = sqrt(x² * p)
    /// L = sqrt(p) * x
    /// liquidity = x * sqrtPrice
    /// x = liquidity / sqprtPrice
    /// xy = k
    /// L² = xy

    ///liquidity = L  = liquidity we want to mint
    function allocate(
        address to,
        uint256 liquidity,
        uint256 sqrtPrice
    ) public returns (uint256 amount0, uint256 amount1) {
        // Compute token amounts required to mint liquidity at price
        amount0 = (liquidity * 1e18) / sqrtPrice; // sqrtPrice = 1e18 units
        amount1 = (amount1 * 1e18) / ((liquidity * liquidity) / 1e18); // 1e18 * 1e18 / (1e18 * 1e18 / 1e18) = 1e18 * 1e18 / 1e18 = 1e18  units

        // set liquidity at sqrtPrice
        ticks[sqrtPrice] = liquidity;

        // handle tokens and minting liquidity
        balanceOf[to][token0] -= amount0;
        balanceOf[to][token1] -= amount1;
        balanceOf[to][address(this)] += liquidity;
    }

    function remove(uint256 amount, uint256 price) public {
        positions[msg.sender][price] -= amount;
        ticks[price] -= amount; // This will revert if tick[price]
    }
}
