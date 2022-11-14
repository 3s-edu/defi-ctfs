// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/src-default/clueless/CluelessLenderPool.sol";
import "src/src-default/clueless/CluelessReceiver.sol";

import "src/src-default/DefiCtfToken.sol";

import "forge-std/Test.sol";

contract CluelessFixture is Test {

    //
    // Constants
    //

    uint256 public constant ETHER_IN_POOL = 1_000 ether;
    uint256 public constant ETHER_IN_RECEIVER = 10 ether;

    //
    // Clueless contracts
    //

    CluelessLenderPool public pool;
    CluelessReceiver public receiver;

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

        // Fund deployer wallet
        vm.deal(deployer, 1010 ether);

        vm.startPrank(deployer);

        // Deploy Safe Receiver contracts
        pool = new CluelessLenderPool();
        receiver = new CluelessReceiver(payable(address(pool)));

        // Fund pool with initial balance
        payable(address(pool)).transfer(ETHER_IN_POOL);

        // Sanity check
        assertEq(address(pool).balance, ETHER_IN_POOL);
        assertEq(pool.fixedFee(), 1 ether);

        // Fund receiver with initial balance
        payable(address(receiver)).transfer(ETHER_IN_RECEIVER);

        // Sanity check
        assertEq(address(receiver).balance, ETHER_IN_RECEIVER);

        vm.stopPrank();
    }
}