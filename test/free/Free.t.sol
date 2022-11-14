// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/FreeFixture.sol";

contract FreeTest is FreeFixture {

    function setUp() public override {
        super.setUp();
    }

    function test_free() public {

        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker);

        /**
         * Code your exploit here
         */

        // Stop acting as the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // Attacker has taken all tokens from the pool
        assertEq(token.balanceOf(attacker), TOKENS_IN_POOL);
        assertEq(token.balanceOf(address(pool)), 0);
    }
}