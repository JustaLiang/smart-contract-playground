// SPDX-License-Identifier: MIT
// Creator: Justa Liang

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/finance/VestingWallet.sol";

/**
 * @title ERC721 with anti-rug-pull mechanism
 * @dev This contract combines ERC721Enumerable and VestingWallet.
 */
abstract contract ERC721AntiRugPull is ERC721Enumerable, VestingWallet {
    /// @notice Thresold of report amount
    uint256 public immutable threshold;

    /// @notice Mint price of each token
    mapping(uint256 => uint256) public tokenMintPrice;

    /// @notice If it's redeemable now (report successfully)
    bool public redeemable;

    /// @notice Cumulative report amount
    uint256 public totalReportAmount;

    /// @notice Returning token amount of each reporter
    mapping(address => uint256) public returningValue;

    /// @dev Setup threshold
    constructor(uint256 _threshold) {
        threshold = _threshold;
        redeemable = false;
        totalReportAmount = 0;
    }

    /// @notice Report using your tokens
    function report(uint256[] calldata tokenIdList) external {
        uint256 amount = tokenIdList.length;
        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = tokenIdList[i];
            require(ownerOf(tokenId) == _msgSender(), "Not owner");
            _transfer(_msgSender(), address(this), tokenId);
            returningValue[_msgSender()] += tokenMintPrice[tokenId];
        }
        totalReportAmount += amount;
    }

    /// @notice Set redeemable if report amount exceed threshold
    function setRedeemable() external {
        require(totalReportAmount >= threshold, "Report amount not enough");
        redeemable = true;
    }

    /// @notice Redeem for reporters
    function redeem() external {
        require(redeemable, "Not redeemable");
        uint256 funding = returningValue[_msgSender()];
        Address.sendValue(
            payable(_msgSender()),
            funding - _vestingSchedule(funding, uint64(block.timestamp))
        );
    }

    /// @notice Redeem if redeemable (report successfully)
    function redeem(uint256[] calldata tokenIdList) external {
        require(redeemable, "Not redeemable");
        uint256 amount = tokenIdList.length;
        uint256 funding = 0;
        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = tokenIdList[i];
            require(ownerOf(tokenId) == _msgSender(), "Not owner");
            _transfer(_msgSender(), address(this), tokenId);
            funding += tokenMintPrice[tokenId];
        }
        Address.sendValue(
            payable(_msgSender()),
            funding - _vestingSchedule(funding, uint64(block.timestamp))
        );
    }

    /// @notice Re-mint from contract
    function reMint(uint256[] calldata tokenIdList) external payable {
        uint256 amount = tokenIdList.length;
        uint256 funding = 0;
        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = tokenIdList[i];
            require(ownerOf(tokenId) == address(this), "Token not in contract");
            _transfer(address(this), _msgSender(), tokenId);
            funding += tokenMintPrice[tokenId];
        }
        require(msg.value >= funding, "Not enough fund");
    }

    /// @dev Mint and record the mint price
    function _mintWithPrice(
        address to,
        uint256 tokenId,
        uint256 mintPrice
    ) internal {
        _mint(to, tokenId);
        tokenMintPrice[tokenId] = mintPrice;
    }

    /// @dev Burn and delete price storage
    function _burn(uint256 tokenId) internal override {
        super._burn(tokenId);
        delete tokenMintPrice[tokenId];
    }
}
