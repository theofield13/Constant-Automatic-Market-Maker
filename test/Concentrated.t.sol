// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Concentrated.sol";

contract TestConcentrated is Test {
    Concentrated public concentrate;

    function setUp() public {
        concentrate = new Concentrated();
        vm.prank(address(0));
        vm.deal(address(0), 100 ether);
    }

    function testSwap() public {
        concentrate.swap(1, 1);
    }
}
