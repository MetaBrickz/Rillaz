// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract SpendingManager is Ownable, IERC721Receiver {
    using SafeERC20 for IERC20;

    mapping(address => uint256) public chainBalances;
    mapping(address => mapping(address => uint256)) public tokenBalances;
    mapping(address => uint256) public nftBalances;

    // Equals to `bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IKIP17Receiver(0).onKIP17Received.selector`
    bytes4 private constant _KIP17_RECEIVED = 0x6745782b;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    constructor() {}

    function deposit() external payable {
        address payable contractAddress = payable(address(this));
        require(contractAddress.send(msg.value), "Transfer failed");
        chainBalances[msg.sender] += msg.value;
    }

    function depositToken(address tokenAddress, uint256 amount) external {
        IERC20 token = IERC20(tokenAddress);
        token.safeTransferFrom(msg.sender, address(this), amount);
        tokenBalances[msg.sender][tokenAddress] += amount;
    }

    function depositNFT(address nftAddress, uint256 tokenId) external {
        IERC721 nft = IERC721(nftAddress);
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        nftBalances[msg.sender] += 1;
    }

    function withdraw(uint256 amount) external {
        require(chainBalances[msg.sender] >= amount, "Insufficient balance");
        chainBalances[msg.sender] -= amount;
        address payable sender = payable(address(msg.sender));
        sender.transfer(amount);
    }

    function withdrawToken(address tokenAddress, uint256 amount) external {
        require(
            tokenBalances[msg.sender][tokenAddress] >= amount,
            "Insufficient token balance"
        );
        tokenBalances[msg.sender][tokenAddress] -= amount;
        IERC20 token = IERC20(tokenAddress);
        token.safeTransfer(msg.sender, amount);
    }

    function withdrawNFT(address nftAddress, uint256 tokenId) external {
        require(nftBalances[msg.sender] >= 1, "Insufficient NFT balance");
        nftBalances[msg.sender] -= 1;
        IERC721 nft = IERC721(nftAddress);
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function getChainBalance(address user) external view returns (uint256) {
        return chainBalances[user];
    }

    function getTokenBalance(
        address user,
        address tokenAddress
    ) external view returns (uint256) {
        return tokenBalances[user][tokenAddress];
    }

    function getNFTBalance(address user) external view returns (uint256) {
        return nftBalances[user];
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