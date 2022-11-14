// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/TheAwarderFixture.sol";

contract TheAwarderTest is TheAwarderFixture {

    function setUp() public override {
        super.setUp();        
    }

    function test_theAwarder() public {

        // NOTE: Block timestamp is at 1 + 5 days

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
        assertEq(theAwarderPool.roundNumber(), 3); // Only one round should have taken place
        for (uint8 i; i < 4; i++) {
            // Users should get negligible awards this round
            vm.prank(users[i]);
            theAwarderPool.distributeAwards();
            uint256 awardPerUser = theAwarderPool.awardToken().balanceOf(
                users[i]
            );
            uint256 delta = awardPerUser - 25e18;
            assertLt(delta, 1e16);
        }
        // Awards must have been issued to the attacker account
        assertGt(theAwarderPool.awardToken().totalSupply(), 100e18);
        uint256 awardAttacker = theAwarderPool.awardToken().balanceOf(
            attacker
        );

        // The amount of awards earned should be really close to 100 tokens
        uint256 deltaAttacker = 100e18 - awardAttacker;
        assertLt(deltaAttacker, 1e17);

        // Attacker finishes with zero DCT tokens in balance
        assertEq(token.balanceOf(attacker), 0);
    }
}