// SPDX-License-Identifier: MIT
// Creator: Justa Liang

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/finance/VestingWallet.sol";

/**
 * @title ERC721 with anti-rug-pull mechanism
 * @dev This contract combines ERC721A, ERC721R and VestingWallet.
 */
abstract contract ERC721RugGripper is ERC721, IERC721Receiver, VestingWallet {
    /// @dev User redeem unowned token
    error NotRedeemByOwner(uint256);

    /// @dev Can't re-mint before mint
    error CanNotReMint(uint256);

    /// @dev Payment lower than amount * price
    error NotEnoughPayment();

    /// @dev Assume all tokens are same price
    uint256 internal _mintPrice;

    /// @dev Setup mint price
    constructor(uint256 mintPrice) {
        _mintPrice = mintPrice;
    }

    /// @notice Redeem owned tokens and get back partial fund
    function redeem(uint256[] calldata tokenIdList) public {
        uint256 amount = tokenIdList.length;
        uint256 funding = 0;
        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = tokenIdList[i];
            if (ownerOf(tokenId) != _msgSender())
                revert NotRedeemByOwner(tokenId);
            safeTransferFrom(_msgSender(), address(this), tokenId);
            funding += _mintPrice;
        }
        Address.sendValue(
            payable(_msgSender()),
            funding - _vestingSchedule(funding, uint64(block.timestamp))
        );
    }

    /// @notice Re-mint tokens after they are give back to contract
    function reMint(uint256[] calldata tokenIdList) external payable {
        uint256 amount = tokenIdList.length;
        uint256 payment = 0;
        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = tokenIdList[i];
            if (ownerOf(tokenId) != address(this)) revert CanNotReMint(tokenId);
            _safeTransfer(address(this), _msgSender(), tokenId, "");
            payment += _mintPrice;
        }
        if (msg.value < payment) revert NotEnoughPayment();
    }

    /// @notice Override ERC721A__IERC721Receiver.onERC721Received
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public virtual override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
