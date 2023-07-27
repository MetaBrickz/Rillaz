// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./IERC721NFTBase.sol";


contract ERC721NFTBase is
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable,
    AccessControlEnumerable,
    ERC721URIStorage,
    IERC721NFTBase
{
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIdTracker;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    string private baseURI;

    constructor(
        string memory name,
        string memory symbol,
        string memory newbaseURI
    ) ERC721(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(OWNER_ROLE, msg.sender);
        baseURI = newbaseURI;
    }

    function safeMintWithTokenId(
        address to,
        uint256 tokenId
    ) external onlyRole(MINTER_ROLE) returns (uint256) {
        require(!_exists(tokenId), "Token ID already exists");
        _safeMint(to, tokenId);
        if (tokenId > _tokenIdTracker.current()) {
            _tokenIdTracker.increment();
        }
        return tokenId;
    }

    function _baseURI()
        internal
        view
        virtual
        override(ERC721)
        returns (string memory)
    {
        return baseURI;
    }

    function setBaseURI(
        string memory newbaseURI
    ) external onlyRole(OWNER_ROLE) {
        baseURI = newbaseURI;
    }

    function transferOwnership(address newOwner) public onlyRole(OWNER_ROLE) {
        require(newOwner != address(0), "New owner cannot be zero address");
        revokeRole(OWNER_ROLE, msg.sender);
        grantRole(OWNER_ROLE, newOwner);
    }

    function getNextTokenId() external view returns (uint256) {
        return _tokenIdTracker.current() + 1;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        require(_exists(tokenId), "Token does not exist");
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function withdraw() external onlyRole(MINTER_ROLE) {
      // This will transfer the remaining contract balance to the owner.
      // Do not remove this otherwise you will not be able to withdraw the funds.
      // =============================================================================
      payable(msg.sender).transfer(address(this).balance);
      // =============================================================================
    }

    function pause() public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
