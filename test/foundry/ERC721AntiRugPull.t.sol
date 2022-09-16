// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../contracts/mock/ERC721AntiRugPullMock.sol";

contract ERC721AntiRugPullTest is Test {
    ERC721AntiRugPullMock public MockARP;
    uint256 public maxSupply;
    uint256 public reportThreshold;
    uint256 public mintPrice;
    address public beneficiary;
    uint256 public start;
    uint256 public duration;
    address public alice;

    function setUp() public {
        MockARP = new ERC721AntiRugPullMock();
        maxSupply = MockARP.MAX_SUPPLY();
        reportThreshold = MockARP.REPORT_THRESHOLD();
        mintPrice = MockARP.MINT_PRICE();
        beneficiary = MockARP.beneficiary();
        start = MockARP.start();
        duration = MockARP.duration();
        alice = makeAddr("alice");
    }

    function testMint() public {
        uint256 amount = 3;
        hoax(alice);
        uint256 fund = mintPrice * amount;
        MockARP.mint{value: fund}(amount);
        assertTrue(MockARP.totalSupply() == amount);
        assertTrue(MockARP.balanceOf(alice) == amount);
        assertTrue(address(MockARP).balance == fund);
    }

    function testFailCantSetRedeemable() public {
        _aliceMintOverThreshold();
        MockARP.setRedeemable();
    }

    function testSetRedeemable() public {
        _aliceMintOverThreshold();
        uint256[] memory tokenIdList = new uint256[](MockARP.balanceOf(alice));
        for (uint256 i = 0; i < tokenIdList.length; ++i) {
            tokenIdList[i] = MockARP.tokenOfOwnerByIndex(alice, i);
        }
        hoax(alice);
        MockARP.report(tokenIdList);
        MockARP.setRedeemable();
        assertTrue(MockARP.redeemable());
    }

    function _aliceMintOverThreshold() private {
        hoax(alice);
        uint256 fund = mintPrice * reportThreshold;
        MockARP.mint{value: fund}(reportThreshold);
    }
}
