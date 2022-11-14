// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

import "src/src-default/doubleAgent/Exchange.sol";
import "src/src-default/doubleAgent/TrustfulOracle.sol";
import "src/src-default/doubleAgent/TrustfulOracleInitializer.sol";
import "src/src-default/DefiCtfNFT.sol";

contract DoubleAgentFixture is Test {

    //
    // Constants
    //
    
    uint256 internal constant EXCHANGE_INITIAL_ETH_BALANCE = 9990e18;
    uint256 internal constant INITIAL_NFT_PRICE = 999e18;

    //
    // Exchange contracts
    //

    Exchange internal exchange;
    TrustfulOracle internal trustfulOracle;
    TrustfulOracleInitializer internal trustfulOracleInitializer;

    //
    // Token contract
    //

    DefiCtfNFT internal defiCtfNFT;

    // Attacker address
    address public attacker = vm.addr(1500);
    // Deployer address
    address public deployer = vm.addr(1502);

    function setUp() public virtual {
        // Label addresses
        vm.label(deployer, "Deployer");
        vm.label(attacker, "Attacker");

        // Fund wallets
        vm.deal(deployer, EXCHANGE_INITIAL_ETH_BALANCE);
        vm.deal(attacker, 0.1 ether);

        vm.startPrank(deployer);

        address[] memory sources = new address[](3);

        sources[0] = 0xA73209FB1a42495120166736362A1DfA9F95A105;
        sources[1] = 0xe92401A4d3af5E446d93D11EEc806b1462b39D15;
        sources[2] = 0x81A5D6E50C214044bE44cA0CB057fe119097850c;

        // Initialize balance of the trusted source addresses
        uint256 arrLen = sources.length;
        for (uint8 i = 0; i < arrLen; ) {
            vm.deal(sources[i], 2 ether);
            assertEq(sources[i].balance, 2 ether);
            unchecked {
                ++i;
            }
        }

        string[] memory symbols = new string[](3);
        for (uint8 i = 0; i < arrLen; ) {
            symbols[i] = "DCNFT";
            unchecked {
                ++i;
            }
        }

        uint256[] memory initialPrices = new uint256[](3);
        for (uint8 i = 0; i < arrLen; ) {
            initialPrices[i] = INITIAL_NFT_PRICE;
            unchecked {
                ++i;
            }
        }

        // Deploy the oracle and setup the trusted sources with initial prices
        trustfulOracle = new TrustfulOracleInitializer(
            sources,
            symbols,
            initialPrices
        ).oracle();

        // Deploy the exchange and get the associated ERC721 token
        exchange = new Exchange{value: EXCHANGE_INITIAL_ETH_BALANCE}(
            address(trustfulOracle)
        );
        defiCtfNFT = exchange.token();

        vm.stopPrank();
    }
}