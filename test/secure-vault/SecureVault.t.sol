// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/SecureVaultFixture.sol";

contract SecureVaultTest is SecureVaultFixture {

    function setUp() public override {
        super.setUp();        
    }

    function test_secureVault() public {

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

    function _assertions() public {
        // Attacker has drained the vault
        assertEq(token.balanceOf(address(secureVault)), 0);
        assertEq(token.balanceOf(attacker), VAULT_TOKEN_BALANCE);
    }
}