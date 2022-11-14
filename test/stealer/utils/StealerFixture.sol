// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/src-default/stealer/StealerBuyer.sol";
import "src/src-default/stealer/StealerNFTMarketplace.sol";

import "src/src-default/DefiCtfNFT.sol";
import "src/src-default/DefiCtfToken.sol";
import "src/src-default/WETH9.sol";

import "forge-std/Test.sol";

contract StealerFixture is Test {

    //
    // Constants
    //

    uint256 public constant NFT_PRICE = 15 ether;
    uint8 public constant AMOUNT_OF_NFTS = 6;
    uint256 public constant MARKETPLACE_INITIAL_ETH_BALANCE = 90 ether;

    uint256 public constant BUYER_PAYOUT = 45 ether;

    uint256 public constant UNISWAP_INITIAL_TOKEN_RESERVE = 15_000 ether;
    uint256 public constant UNISWAP_INITIAL_WETH_RESERVE = 9_000 ether;

    //
    // Token contracts
    //

    WETH9 public weth;
    DefiCtfToken public token;
    DefiCtfNFT public nft;

    //
    // Uniswap V2 contracts
    //

    address public factory;
    address public router;
    address public pair;

    //
    // Marketplace
    //

    StealerNFTMarketplace public marketplace;

    //
    // Buyer contract
    //

    StealerBuyer public buyerContract;


    // Attacker address
    address public attacker = vm.addr(1500);
    // Deployer address
    address public deployer = vm.addr(1501);
    // Buyer address
    address public buyer = vm.addr(1502);

    // Helper arrays
    uint256[] public ids;
    uint256[] public prices;

    function setUp() public virtual {
        // Label addresses
        vm.label(attacker, "Attacker");
        vm.label(deployer, "Deployer");

        // Fund deployer wallet
        vm.deal(deployer, 9090 ether);
        // Fund attacker's wallet
        vm.deal(attacker, 0.5 ether);
        // Fund buyer's wallet
        vm.deal(buyer, BUYER_PAYOUT);

        vm.startPrank(deployer);

        // Deploy Token contracts
        weth = new WETH9();
        token = new DefiCtfToken();

        // Setup Uniswap V2 contracts
        factory = deployCode("UniswapV2Factory.sol", abi.encode(address(0)));
        vm.label(factory, "Factory");
        router = deployCode("UniswapV2Router02.sol", abi.encode(address(factory), address(weth)));
        vm.label(router, "Router");

        // Create Uniswap V2 pair and add liquidity
        token.approve(router, UNISWAP_INITIAL_TOKEN_RESERVE);
        (bool success, ) = router.call{value: UNISWAP_INITIAL_WETH_RESERVE}(abi.encodeWithSignature(
                "addLiquidityETH(address,uint256,uint256,uint256,address,uint256)",
                address(token),
                UNISWAP_INITIAL_TOKEN_RESERVE,
                0,
                0,
                deployer,
                block.timestamp * 2
            )
        );
        require(success, "addLiquidityETH failed");

        // Get a reference to the created pair
        (, bytes memory data) = factory.call(abi.encodeWithSignature("getPair(address,address)", address(token), address(weth)));
        pair = abi.decode(data, (address));

        // Sanity check
        (, data) = pair.call(abi.encodeWithSignature("token0()"));
        address token0 = abi.decode(data, (address));
        assertEq(token0, address(weth));
        (, data) = pair.call(abi.encodeWithSignature("token1()"));
        address token1 = abi.decode(data, (address));
        assertEq(token1, address(token));
        (, data) = pair.call(abi.encodeWithSignature("balanceOf(address)", deployer));
        uint256 balance = abi.decode(data, (uint256));
        assertGt(balance, 0);

        // Deploy the marketplace and get the ERFC721 contract
        marketplace = new StealerNFTMarketplace{value: MARKETPLACE_INITIAL_ETH_BALANCE}(AMOUNT_OF_NFTS);
        nft = DefiCtfNFT(marketplace.token());

        // Ensure deployer owns all NFTs
        for (uint id = 0; id < AMOUNT_OF_NFTS; id++)
            assertEq(nft.ownerOf(id), deployer);

        // Open offers in the marketplace
        nft.setApprovalForAll(address(marketplace), true);
        ids.push(0);
        ids.push(1);
        ids.push(2);
        ids.push(3);
        ids.push(4);
        ids.push(5);
        prices.push(NFT_PRICE);
        prices.push(NFT_PRICE);
        prices.push(NFT_PRICE);
        prices.push(NFT_PRICE);
        prices.push(NFT_PRICE);
        prices.push(NFT_PRICE);
        marketplace.offerMany(
            ids,
            prices
        );

        // Sanity check
        assertEq(marketplace.amountOfOffers(), 6);

        vm.stopPrank();

        // Deploy buyer's contract
        vm.prank(buyer);
        buyerContract = new StealerBuyer{value: BUYER_PAYOUT}(attacker, address(nft));
    }
}