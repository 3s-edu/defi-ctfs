pragma solidity >0.8.0;

import "./utils/OvercollateralizedV2Fixture.sol";

contract OvercollateralizedV2Test is OvercollateralizedV2Fixture {

    function setUp() public override {
        super.setUp();
    }

    function test_overcollateralized_v2() public {

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
        // The lending pool has no tokens left.
        assertEq(token.balanceOf(pool), 0);
        // The attacker has all the tokens.
        assertGe(token.balanceOf(attacker), POOL_INITIAL_TOKEN_BALANCE);
    }
}