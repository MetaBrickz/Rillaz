// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./IERC721NFTBase.sol";


contract FusionManager is Ownable, IERC721Receiver {
    struct FusionConfig {
        address nftContract1;
        address nftContract2;
        address nftContractResult;
    }

    struct FusionPerform {
        address nftContract1;
        uint256 tokenId1;
        address nftContract2;
        uint256 tokenId2;
    }

    mapping(address => bool) public eligibleNftContracts;
    mapping(bytes32 => bool) public eligibleFusions;
    mapping(bytes32 => bool) public usedFusions;
    mapping(bytes32 => address) public fusionResultContracts;

    event FusionEligibilitySet(address indexed nftContract, bool eligible);
    event FusionConfigSet(
        address indexed nftContract1,
        address indexed nftContract2,
        address nftContractResult
    );
    event FusionPerformed(
        uint256 indexed tokenId1,
        uint256 indexed tokenId2,
        uint256 tokenIdResult
    );

    // Equals to `bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IKIP17Receiver(0).onKIP17Received.selector`
    bytes4 private constant _KIP17_RECEIVED = 0x6745782b;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    function setEligibleNftContract(
        address nftContract,
        bool eligible
    ) external onlyOwner {
        eligibleNftContracts[nftContract] = eligible;
        emit FusionEligibilitySet(nftContract, eligible);
    }

    function setFusionConfig(
        address nftContract1,
        address nftContract2,
        address nftContractResult
    ) external onlyOwner {
        require(
            eligibleNftContracts[nftContract1],
            "NFT contract 1 not eligible for fusion"
        );
        require(
            eligibleNftContracts[nftContract2],
            "NFT contract 2 not eligible for fusion"
        );
        bytes32 fusionHash = getFusionHash(nftContract1, nftContract2);
        eligibleFusions[fusionHash] = true;
        fusionResultContracts[fusionHash] = nftContractResult;
        emit FusionConfigSet(nftContract1, nftContract2, nftContractResult);
    }

    function performFusion(
        address nftContract1,
        uint256 tokenId1,
        address nftContract2,
        uint256 tokenId2
    ) external {
        require(
            eligibleFusions[getFusionHash(nftContract1,nftContract2)],
            "Fusion configuration not found or not eligible"
        );

        bytes32 fusionHash = getFusionPerformHash(nftContract1, tokenId1, nftContract2, tokenId2);

        require(
            !usedFusions[fusionHash],
            "Fusion already performed with this pair of tokens"
        );
        usedFusions[fusionHash] = true;
        FusionConfig memory config = getFusionConfig(
            nftContract1,
            nftContract2
        );
        IERC721(config.nftContract1).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId1
        );
        IERC721(config.nftContract2).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId2
        );

        uint256 tokenIdResult = IERC721NFTBase(config.nftContractResult).getNextTokenId();
        IERC721NFTBase(config.nftContractResult).safeMintWithTokenId(msg.sender, tokenIdResult);

        emit FusionPerformed(
            tokenId1,
            tokenId2,
            tokenIdResult
        );
    }

    function getFusionConfig(
        address nftContract1,
        address nftContract2
    ) public view returns (FusionConfig memory) {
        bytes32 fusionHash = getFusionHash(
            nftContract1,
            nftContract2
        );
        require(
            eligibleFusions[fusionHash],
            "Fusion configuration not found or not eligible"
        );

        FusionConfig memory config;
        config.nftContract1 = nftContract1;
        config.nftContract2 = nftContract2;
        config.nftContractResult = fusionResultContracts[fusionHash];
        return config;
    }

    function getFusionHash(
        address nftContract1,
        address nftContract2
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(nftContract1, nftContract2));
    }

    function getFusionPerformHash(
        address nftContract1,
        uint256 tokenId1,
        address nftContract2,
        uint256 tokenId2
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(nftContract1, tokenId1, nftContract2, tokenId2)
            );
    }

    function transferOwnership(address newOwner) public override(Ownable) onlyOwner {
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
