// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/SafeRegistryFixture.sol";

contract SafeRegistryTest is SafeRegistryFixture {

    function setUp() public override {
        super.setUp();
    }

    function test_safeRegistry() public {

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
        address wallet;
        for (uint i = 0; i < users.length; i++) {
            wallet = safeRegistry.wallets(users[i]);
            
            // Users do in fact have a wallet.
            assert(wallet != address(0));

            // Users are no longer registered as beneficiaries.
            assertFalse(safeRegistry.beneficiaries(users[i]));
        }

        // The attacker has all the tokens.
        assertEq(token.balanceOf(attacker), AMOUNT_TOKENS_DISTRIBUTED);
    }
}