// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/FlashBankFixture.sol";

contract FlashBankTest is FlashBankFixture {
    
    function setUp() public override {
        super.setUp();
    }

    function test_flashBank() public {
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
        // Verify the attacker drained the pool's funds
        assertEq(address(pool).balance, 0);
        assertGt(attacker.balance, ATTACKER_INITIAL_BALANCE);
    }
}