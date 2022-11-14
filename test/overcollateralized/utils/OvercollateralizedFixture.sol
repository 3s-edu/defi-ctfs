// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/src-default/overcollateralized/OvercollateralizedPool.sol";

import "src/src-default/WETH9.sol";
import "src/src-default/DefiCtfToken.sol";

import "forge-std/Test.sol";

contract OvercollateralizedFixture is Test {

    //
    // Constants
    //

    uint256 public constant UNISWAP_INITIAL_TOKEN_RESERVE = 10 ether;
    uint256 public constant UNISWAP_INITIAL_ETH_RESERVE = 10 ether;

    uint256 public constant ATTACKER_INITIAL_TOKEN_BALANCE = 1_000 ether;
    uint256 public constant ATTACKER_INITIAL_ETH_BALANCE = 25 ether;
    uint256 public constant POOL_INITIAL_TOKEN_BALANCE = 100_000 ether;

    //
    // Token contracts
    //

    WETH9 public weth;
    DefiCtfToken public token;

    //
    // Uniswap V1 contracts
    //

    address public exchangeTemplate;
    address public factory;
    address public exchange;

    //
    // Pool
    //

    OvercollateralizedPool public pool;

    // Attacker address
    address public attacker = vm.addr(1500);
    // Deployer address
    address public deployer = vm.addr(1501);

    function setUp() public virtual {
        // Label addresses
        vm.label(attacker, "Attacker");
        vm.label(deployer, "Deployer");

        // Initial attacker balance
        vm.deal(attacker, ATTACKER_INITIAL_ETH_BALANCE);
        // Fund deployer wallet
        vm.deal(deployer, 1000 ether);

        vm.startPrank(deployer);

        // Setup Token contracts
        weth = new WETH9();
        token = new DefiCtfToken();

        // Setup Uniswap V1 contracts
        exchangeTemplate = deployCode("build-uniswap-v1/UniswapV1Exchange.json");
        factory = deployCode("build-uniswap-v1/UniswapV1Factory.json");
        vm.label(exchangeTemplate, "exchangeTemplate");
        vm.label(factory, "factory");
        // Initialize factory contract with exchange template
        (bool success, ) = factory.call(abi.encodeWithSignature("initializeFactory(address)", exchangeTemplate));
        require(success, "initializeFactory failed");
        // Create exchange for token
        (, bytes memory data) = factory.call(abi.encodeWithSignature("createExchange(address)", address(token)));
        exchange = abi.decode(data, (address));
        vm.label(exchange, "exchange");

        // Deploy the Pool
        pool = new OvercollateralizedPool(
            address(token),
            exchange
        );

        // Add liquidity to the pool
        token.approve(exchange, UNISWAP_INITIAL_TOKEN_RESERVE);
        (success, ) = exchange.call{value: UNISWAP_INITIAL_ETH_RESERVE}(abi.encodeWithSignature(
            "addLiquidity(uint256,uint256,uint256)", 
            0, 
            UNISWAP_INITIAL_TOKEN_RESERVE, 
            block.timestamp * 2
        ));
        require(success, "addLiquidity failed");

        // Ensure Uniswap V1 works as expected
        (, data) = exchange.call(abi.encodeWithSignature("getTokenToEthInputPrice(uint256)", 1 ether));
        uint256 price = abi.decode(data, (uint256));
        assertEq(price, calculateTokenToEthInputPrice(1 ether, UNISWAP_INITIAL_TOKEN_RESERVE, UNISWAP_INITIAL_ETH_RESERVE));

        // Setup initial token balances
        token.transfer(attacker, ATTACKER_INITIAL_TOKEN_BALANCE);
        token.transfer(address(pool), POOL_INITIAL_TOKEN_BALANCE);

        // Ensure correct pool setup
        assertEq(pool.calculateDepositRequired(1 ether), 2 ether);
        assertEq(pool.calculateDepositRequired(POOL_INITIAL_TOKEN_BALANCE), POOL_INITIAL_TOKEN_BALANCE * 2);

        vm.stopPrank();
    }

    //
    // Helper functions
    //
    
    function calculateTokenToEthInputPrice(
        uint256 tokensSold, 
        uint256 tokensInReserve, 
        uint256 etherInReserve
    ) public pure returns (uint256){

        return tokensSold * 997 * etherInReserve / (tokensInReserve * 1000 + tokensSold * 997);
    }

}