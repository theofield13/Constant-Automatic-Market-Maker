// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Concentrated.sol";

contract TestConcentrated is Test {
    Concentrated public concentrate;

    address public user;
    address public token0;
    address public token1;

    function setUp() public {
        concentrate = new Concentrated();
        vm.prank(address(0));
        vm.deal(address(0), 100 ether);

        user = address(0x01);
        token0 = address(0x04);
        token0 = address(0x05);

        concentrate.setToken(token0, token1);
        concentrate.setBalance(user, token0, 100 ether);
    }

    uint256 public constant SCALAR = 1e18;

    function allocate() public returns (uint256 amount0, uint256 amount1) {
        vm.prank(user);
        uint256 liquidity = 1 * SCALAR;
        uint256 priceIndex = 1;
        uint256 sqrtPrice = concentrate.sqrtGrid(priceIndex) * SCALAR;
        (amount0, amount1) = concentrate.allocate(user, liquidity, sqrtPrice);

        assertEq(concentrate.balanceOf(user, address(concentrate)), liquidity);
    }

    function testAllocate() public {
        (uint256 amount0, uint256 amount1) = allocate();
        console.log("Allocated:");
        console.log(amount0);
        console.log(amount1);
    }

    function testSwap() public {
        vm.prank(user);
        uint256 amount = 750;
        uint256 limitPrice = 0;

        (uint256 price, uint256 amountIn, uint256 amountOut) = concentrate.swap(
            amount,
            limitPrice
        );
        console.log(price);
        console.log(amountIn);
        console.log(amountOut);

        assertGt(concentrate.balanceOf(user, token1), 0);
    }
}
