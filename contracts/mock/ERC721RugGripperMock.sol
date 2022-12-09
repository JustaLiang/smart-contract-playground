// SPDX-License-Identifier: MIT
// Creators: Justa Liang

pragma solidity ^0.8.13;

import "../ERC721RugGripper.sol";

/**
 * @title Testing the usage of ERC721RugGripper
 */
contract ERC721RugGripperMock is ERC721RugGripper {
    /// @notice Max supply
    uint256 public constant MAX_SUPPLY = 100;

    /// @notice Mint price
    uint256 public constant MINT_PRICE = 0.1 ether;

    /// @notice Duration sec
    uint64 public constant DURATION_SEC = 8 weeks;

    uint256 public totalSupply;

    /// @dev Setup ERC721, VestingWallet
    constructor()
        ERC721("RugGripper", "RUGR")
        VestingWallet(
            _msgSender(),
            uint64(block.timestamp + 1 weeks),
            DURATION_SEC
        )
        ERC721RugGripper(MINT_PRICE)
    {
        totalSupply = 0;
    }

    /// @notice Public mint
    function publicMint(uint256 amount) external payable {
        require(totalSupply + amount <= MAX_SUPPLY, "exceed max supply");
        require(msg.value >= _mintPrice * amount, "not enough payment");
        uint256 i = 0;
        while (i++ < amount) {
            _safeMint(_msgSender(), totalSupply++);
        }
    }
}
