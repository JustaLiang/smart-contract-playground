// SPDX-License-Identifier: MIT
// Creators: Justa Liang

pragma solidity ^0.8.13;

import "../ERC721AntiRugPull.sol";

/**
 * @title Testing the usage of ERC721AntiRugPull
 */
contract ERC721AntiRugPullMock is ERC721AntiRugPull {
    /// @notice Max supply
    uint256 public constant MAX_SUPPLY = 100;

    /// @notice Report threshold
    uint256 public constant REPORT_THRESHOLD = 20;

    /// @notice Mint price
    uint256 public constant MINT_PRICE = 0.1 ether;

    /// @notice Duration sec
    uint64 public constant DURATION_SEC = 1 weeks;

    /// @dev Setup ERC721, VestingWallet and the report threshold
    constructor()
        ERC721("RugGripper", "RUGR")
        VestingWallet(
            _msgSender(),
            uint64(block.timestamp + 10 minutes),
            DURATION_SEC
        )
        ERC721AntiRugPull(REPORT_THRESHOLD)
    {}

    /// @notice Mint
    function mint(uint256 amount) external payable {
        uint256 newTokenId = totalSupply();
        require(msg.value >= amount * MINT_PRICE, "not enough fund");
        require(newTokenId + amount <= MAX_SUPPLY, "exceed max supply");
        for (uint256 i = 0; i < amount; ++i) {
            _mintWithPrice(_msgSender(), newTokenId++, MINT_PRICE);
        }
    }
}
