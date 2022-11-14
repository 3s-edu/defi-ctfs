// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/src-default/free/FreeLenderPool.sol";

import "src/src-default/DefiCtfToken.sol";

import "forge-std/Test.sol";

contract FreeFixture is Test {

    //
    // Constants
    //

    uint256 public constant TOKENS_IN_POOL = 1_000_000 ether;

    //
    // Token contract
    //

    DefiCtfToken public token;

    //
    // Pool
    //

    FreeLenderPool public pool;

    // Attacker address
    address public attacker = vm.addr(1500);
    // Deployer address
    address public deployer = vm.addr(1501);

    function setUp() public virtual {
        // Label addresses
        vm.label(attacker, "Attacker");
        vm.label(deployer, "Deployer");

        vm.startPrank(deployer);

        // Setup Token contract
        token = new DefiCtfToken();

        // Setup Pool contract
        pool = new FreeLenderPool(address(token));

        // Fund pool with tokens
        token.transfer(address(pool), TOKENS_IN_POOL);

        // Sanity check
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(token.balanceOf(attacker), 0);

        vm.stopPrank();
    }
}