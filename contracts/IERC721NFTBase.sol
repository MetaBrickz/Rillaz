// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC721NFTBase {
    function safeMintWithTokenId(
        address to,
        uint256 tokenId
    ) external returns (uint256);

    function getNextTokenId() external view returns (uint256);
}
