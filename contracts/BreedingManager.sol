// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./IERC721NFTBase.sol";

contract BreedingManager is Ownable, IERC721Receiver {
    struct Parent {
        uint256 tokenId;
        address owner;
    }

    mapping(uint256 => Parent[2]) public parents;
    mapping(uint256 => uint256) public childToGeneration;
    address public nftContract;

    // Equals to `bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IKIP17Receiver(0).onKIP17Received.selector`
    bytes4 private constant _KIP17_RECEIVED = 0x6745782b;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    constructor() {}

    function breed(
        uint256 tokenId1,
        uint256 tokenId2,
        uint256 generation
    ) external onlyOwner returns (uint256) {
        require(tokenId1 != tokenId2, "The tokens provided must be different");

        IERC721 erc721Nft = IERC721(nftContract);
        require(
            erc721Nft.ownerOf(tokenId1) == msg.sender,
            "The first token provided must be owned by the sender"
        );
        require(
            erc721Nft.ownerOf(tokenId2) == msg.sender,
            "The second token provided must be owned by the sender"
        );

        Parent memory parent1 = parents[tokenId1][0].owner == address(0)
            ? Parent(tokenId1, msg.sender)
            : parents[tokenId1][0];
        Parent memory parent2 = parents[tokenId2][0].owner == address(0)
            ? Parent(tokenId2, msg.sender)
            : parents[tokenId2][0];
        require(
            generation > childToGeneration[parent1.tokenId] &&
                generation > childToGeneration[parent2.tokenId],
            "The specified generation must be greater than the parent generations"
        );

        uint256 newTokenId = uint256(
            keccak256(abi.encodePacked(tokenId1, tokenId2, generation))
        );

        IERC721NFTBase(nftContract).safeMintWithTokenId(msg.sender, newTokenId);

        parents[newTokenId][0] = parent1;
        parents[newTokenId][1] = parent2;
        childToGeneration[newTokenId] = generation;

        return newTokenId;
    }

    function transferOwnership(
        address newOwner
    ) public override(Ownable) onlyOwner {
        super.transferOwnership(newOwner);
    }

    ///////////
    /// Reciever//
    /////////////
    event KIP17Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes data,
        uint256 gas
    );

    function onKIP17Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4) {
        emit KIP17Received(operator, from, tokenId, data, gasleft());
        return _KIP17_RECEIVED;
    }

    event ERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes data,
        uint256 gas
    );

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4) {
        emit ERC721Received(operator, from, tokenId, data, gasleft());
        return _ERC721_RECEIVED;
    }
}
