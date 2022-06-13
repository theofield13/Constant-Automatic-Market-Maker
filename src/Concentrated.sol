// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Contract {
    constructor() payable {}

    function allocate(
        address to,
        uint256 amount,
        uint256 price
    ) public {}

    function swap(
        uint256 direction,
        uint256 amount,
        uint256 price
    ) public {}

    function remove(uint256 amount, uint256 price) public {}
}
