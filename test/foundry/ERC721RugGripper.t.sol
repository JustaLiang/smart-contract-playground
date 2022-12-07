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
    address public alice;

    function setUp() public {
        MockRG = new ERC721RugGripperMock();
        maxSupply = MockRG.MAX_SUPPLY();
        mintPrice = MockRG.MINT_PRICE();
        beneficiary = MockRG.beneficiary();
        start = MockRG.start();
        duration = MockRG.duration();
        alice = makeAddr("alice");
    }

    function testMint() public {
        uint256 amount = 3;
        hoax(alice);
        uint256 fund = mintPrice * amount;
        MockRG.publicMint{value: fund}(amount);
        assertTrue(MockRG.totalSupply() == amount);
        assertTrue(MockRG.balanceOf(alice) == amount);
        assertTrue(address(MockRG).balance == fund);
    }
}
