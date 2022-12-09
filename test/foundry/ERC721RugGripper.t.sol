// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../contracts/mock/ERC721RugGripperMock.sol";

contract ERC721RugGripperTest is Test {
    ERC721RugGripperMock public MockRG;
    uint256 public maxSupply;
    uint256 public mintPrice;
    address public beneficiary;
    uint256 public start;
    uint256 public duration;
    address public contractAddr;
    address public deployer;
    address public alice;
    address public bob;

    function setUp() public {
        deployer = makeAddr("deployer");
        MockRG = new ERC721RugGripperMock(deployer);
        maxSupply = MockRG.MAX_SUPPLY();
        mintPrice = MockRG.MINT_PRICE();
        beneficiary = MockRG.beneficiary();
        start = MockRG.start();
        duration = MockRG.duration();
        contractAddr = address(MockRG);
        alice = makeAddr("alice");
        bob = makeAddr("bob");
    }

    function testMint() public {
        uint256 amount = 3;
        uint256 fund = mintPrice * amount;
        hoax(alice);
        MockRG.publicMint{value: fund}(amount);
        assertTrue(MockRG.totalSupply() == amount, "mint: wrong supply");
        assertTrue(
            MockRG.balanceOf(alice) == amount,
            "mint: wrong user NFT balance"
        );
        assertTrue(contractAddr.balance == fund, "mint: wrong contract fund");
    }

    function testFailMint() public {
        uint256 amount = 2;
        uint256 fund = mintPrice;
        hoax(alice);
        MockRG.publicMint{value: fund}(amount);
    }

    function testRedeem() public {
        testMint();
        uint256 holdAmount = MockRG.balanceOf(alice);
        uint256 backAmount = 2;
        uint256 leftAmount = holdAmount - backAmount;
        uint256[] memory tokenIdList = new uint256[](backAmount);
        tokenIdList[0] = 0;
        tokenIdList[1] = 1;
        uint256 aliceBalanceBeforeRedeem = alice.balance;
        vm.prank(alice);
        MockRG.redeem(tokenIdList);
        assertTrue(MockRG.totalSupply() == holdAmount, "redeem: wrong supply");
        assertTrue(
            MockRG.balanceOf(alice) == holdAmount - backAmount,
            "redeem: wrong user NFT balance"
        );
        assertTrue(
            MockRG.balanceOf(contractAddr) == backAmount,
            "redeem: wrong contract NFT balance"
        );
        assertTrue(
            MockRG.ownerOf(0) == contractAddr,
            "redeem: token #0 wrong owner"
        );
        assertTrue(
            MockRG.ownerOf(1) == contractAddr,
            "redeem: token #1 wrong owner"
        );
        assertTrue(
            contractAddr.balance == leftAmount * mintPrice,
            "redeem: wrong contract fund"
        );
        assertTrue(
            alice.balance - aliceBalanceBeforeRedeem == backAmount * mintPrice,
            "redeem: wrong redemption fund"
        );
    }

    function testFailRedeem() public {
        testMint();
        uint256[] memory tokenIdList = new uint256[](1);
        tokenIdList[0] = 4;
        vm.prank(alice);
        MockRG.redeem(tokenIdList);
    }

    function testReMint() public {
        testRedeem();
        uint256[] memory tokenIdList = new uint256[](2);
        tokenIdList[0] = 0;
        tokenIdList[1] = 1;
        hoax(bob);
        MockRG.reMint{value: 2 * mintPrice}(tokenIdList);
        assertTrue(
            MockRG.balanceOf(bob) == 2,
            "reMint: wrong user NFT balance"
        );
        assertTrue(
            MockRG.balanceOf(contractAddr) == 0,
            "reMint: wrong contract NFT balance"
        );
        assertTrue(
            contractAddr.balance == 3 * mintPrice,
            "reMint: wrong contract fund"
        );
    }
}
