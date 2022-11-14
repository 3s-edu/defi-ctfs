// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/StealerFixture.sol";

contract StealerTest is StealerFixture {

    function setUp() public override {
        super.setUp();
    }

    function test_stealer() public {
        
        // Start acting as the attacker for the remainder of the exploit
        vm.startPrank(attacker, attacker);

        /**
         * Code your exploit here
         */

        // Stop acting as the attacker
        vm.stopPrank();
        // Perform exploit validations
        _assertions();
    }

    function _assertions() internal {
        // Attacker earned all ETH from payout
        assertGt(attacker.balance, BUYER_PAYOUT);
        assertEq(address(buyerContract).balance, 0);

        // The buyer extracts all NFTs from his contract
        vm.startPrank(buyer);
        for (uint id = 0; id < AMOUNT_OF_NFTS; id++) {
            nft.transferFrom(address(buyerContract), buyer, id);
            assertEq(nft.ownerOf(id), buyer);
        }
        vm.stopPrank();

        // Exchange lost all NFTs and ETH
        assertEq(marketplace.amountOfOffers(), 0);
        assertLt(address(marketplace).balance, MARKETPLACE_INITIAL_ETH_BALANCE);
    }
}