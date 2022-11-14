// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/DoubleAgentFixture.sol";

contract DoubleAgent is DoubleAgentFixture {

    function setUp() public override {
        super.setUp();        
    }

    function test_doubleAgent() public {

        /**
         * Code your exploit here
         */

        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // Exchange lost all ETH
        assertEq(address(exchange).balance, 0);
        // Attacker's balance has increased significantly
        assertGt(attacker.balance, EXCHANGE_INITIAL_ETH_BALANCE);
        // Attacker does not own any NFT
        assertEq(defiCtfNFT.balanceOf(attacker), 0);
        // NFT price hasn't changed
        assertEq(trustfulOracle.getMedianPrice("DCNFT"), INITIAL_NFT_PRICE);
    }
}