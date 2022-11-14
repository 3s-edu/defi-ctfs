// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/src-default/governor/GovernorPool.sol";
import "src/src-default/governor/SimpleGovernance.sol";

import "src/src-default/DefiCtfTokenSnapshot.sol";

import "forge-std/Test.sol";

contract GovernorFixture is Test {

    //
    // Constants
    //

    uint256 public constant TOKEN_INITIAL_SUPPLY = 2_000_000 ether;
    uint256 public constant TOKENS_IN_POOL = 1_500_000 ether;

    //
    // Token contracts
    //

    DefiCtfTokenSnapshot public token;
    SimpleGovernance public governance;

    //
    // Pool
    //

    GovernorPool public pool;

    // Attacker address
    address public attacker = vm.addr(1500);
    // Deployer address
    address public deployer = vm.addr(1501);

    function setUp() public virtual {
        // Label addresses
        vm.label(attacker, "Attacker");
        vm.label(deployer, "Deployer");

        vm.startPrank(deployer);

        // Setup Token contracts
        token = new DefiCtfTokenSnapshot(TOKEN_INITIAL_SUPPLY);
        governance = new SimpleGovernance(address(token));

        // Setup Pool
        pool = new GovernorPool(
            address(token),
            address(governance)
        );
        token.transfer(address(pool), TOKENS_IN_POOL);

        // Sanity check
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);

        vm.stopPrank();
    }
}