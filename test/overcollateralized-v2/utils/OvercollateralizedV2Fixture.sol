pragma solidity >0.8.0;

import "src/src-default/DefiCtfToken.sol";
import "src/src-default/WETH9.sol";

import "forge-std/Test.sol";

contract OvercollateralizedV2Fixture is Test {

    //
    // Constants
    //

    uint256 public constant UNISWAP_INITIAL_TOKEN_RESERVE = 100 ether;
    uint256 public constant UNISWAP_INITIAL_WETH_RESERVE = 10 ether;

    uint256 public constant ATTACKER_INITIAL_TOKEN_BALANCE = 10_000 ether;
    uint256 public constant POOL_INITIAL_TOKEN_BALANCE = 1_000_000 ether;

    //
    // Uniswap V2 contracts
    //

    address public factory;
    address public router;
    address public exchange;

    //
    // Pool
    //

    address public pool;

    //
    // Pool tokens
    //

    WETH9 public weth;
    DefiCtfToken public token;

    // Attacker address
    address public attacker = vm.addr(1500);
    // Deployer address
    address public deployer = vm.addr(1501);

    function setUp() public virtual {
        // Label addresses
        vm.label(attacker, "Attacker");
        vm.label(deployer, "Deployer");

        // Inital attacker balance
        vm.deal(attacker, 20 ether);
        // Fund deployer wallet
        vm.deal(deployer, 1000 ether);

        vm.startPrank(deployer);

        //  Setup Token contracts.
        weth = new WETH9();
        token = new DefiCtfToken();
        vm.label(address(weth), "WETH");
        vm.label(address(token), "DCT");

        // Setup Uniswap V2 contracts
        factory = deployCode("UniswapV2Factory.sol", abi.encode(address(0)));
        router = deployCode("UniswapV2Router02.sol", abi.encode(address(factory),address(weth)));
        vm.label(factory, "Factory");
        vm.label(router, "Router");

        // Create pair WETH <-> Token and add liquidity
        token.approve(router, UNISWAP_INITIAL_TOKEN_RESERVE);
        (bool success, ) = router.call{value: UNISWAP_INITIAL_WETH_RESERVE}(
            abi.encodeWithSignature(
                "addLiquidityETH(address,uint256,uint256,uint256,address,uint256)", 
                address(token), 
                UNISWAP_INITIAL_TOKEN_RESERVE, 
                0, 
                0, 
                deployer, 
                block.timestamp * 2
            )
        );
        require(success);

        // Get the pair to interact with
        (, bytes memory data) = factory.call(abi.encodeWithSignature("getPair(address,address)", address(token), address(weth)));
        exchange = abi.decode(data, (address));

        // Sanity check
        (, data) = exchange.call(abi.encodeWithSignature("balanceOf(address)", deployer));
        uint256 deployerBalance = abi.decode(data, (uint256));
        assertGt(deployerBalance, 0);

        // Deploy the pool
        pool = deployCode("OvercollateralizedV2Pool.sol", abi.encode(address(weth),address(token),address(exchange),factory));

        // Setup initial token balance
        token.transfer(attacker, ATTACKER_INITIAL_TOKEN_BALANCE);
        token.transfer(pool, POOL_INITIAL_TOKEN_BALANCE);

        // Sanity checks
        (, data) = pool.call(abi.encodeWithSignature("calculateDepositOfWETHRequired(uint256)", 1 ether));
        uint256 depositRequired = abi.decode(data, (uint256));
        assertEq(depositRequired, 0.3 ether);
        (, data) = pool.call(abi.encodeWithSignature("calculateDepositOfWETHRequired(uint256)", POOL_INITIAL_TOKEN_BALANCE));
        depositRequired = abi.decode(data, (uint256));
        assertEq(depositRequired, 300_000 ether);

        vm.stopPrank();
    }
}