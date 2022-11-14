// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/src-default/flashpool/FlashPoolLender.sol";
import "src/src-default/flashpool/FlashPoolReceiver.sol";

import "src/src-default/DefiCtfToken.sol";

import "forge-std/Test.sol";

contract FlashPoolFixture is Test {

    //
    // Constants
    //

    uint256 public constant TOKENS_IN_POOL = 1_000_000 ether;
    uint256 public constant INITIAL_ATTACKER_TOKEN_BALANCE = 100 ether;

    //
    // Token contract
    //

    DefiCtfToken public token;

    //
    // Flash Pool contracts
    //

    FlashPoolLender public pool;
    FlashPoolReceiver public receiver;

    // Attacker address
    address public attacker = vm.addr(1500);
    // Deployer address
    address public deployer = vm.addr(1501);
    // Random user address
    address public user = vm.addr(1502);

    function setUp() public virtual {
        // Label addresses
        vm.label(attacker, "Attacker");
        vm.label(deployer, "Deployer");

        vm.startPrank(deployer);

        // Setup Token contract
        token = new DefiCtfToken();

        // Deploy the Pool
        pool = new FlashPoolLender(address(token));

        // Deposit initial tokens in pool
        token.approve(address(pool), TOKENS_IN_POOL);
        pool.depositTokens(TOKENS_IN_POOL);

        // Fund attacker address with tokens
        token.transfer(attacker, INITIAL_ATTACKER_TOKEN_BALANCE);

        // Sanity check
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(token.balanceOf(attacker), INITIAL_ATTACKER_TOKEN_BALANCE);

        vm.stopPrank();

        // Show its possible for a user to take out a flash loan
        vm.startPrank(user);
        receiver = new FlashPoolReceiver(address(pool));
        receiver.executeFlashLoan(10);
        
        vm.stopPrank();
    }
}