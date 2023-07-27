pragma solidity ^0.5.0;

import "@klaytn/contracts/KIP/token/KIP17/IKIP17.sol";
import "@klaytn/contracts/KIP/token/KIP7/IKIP7.sol";
import "@klaytn/contracts/access/Ownable.sol";
import "./KIP-7.sol";

contract MetaBrickNftShop is Ownable {
    using SafeMath for uint256;
    MBT public mbtToken;
    address public mbtReceiver;

    // Product info
    struct Product {
        string preRequiredSoldOutProductId;
        IKIP17 nftContractAddress;
        uint256[] tokenIds;
        uint256 purchasedAmount;
        uint256 totalAmount;
        uint256 mbtPrice;
    }

    // Mapping of User Address to Staker info
    mapping(string => Product) public products;

    bool public shopEnabled = false;

    // Equals to `bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IKIP17Receiver(0).onKIP17Received.selector`
    bytes4 private constant _KIP17_RECEIVED = 0x6745782b;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Constructor function
    constructor(
        MBT _mbtToken,
        address _mbtReceiver
    ) public {
        mbtToken = _mbtToken;
        mbtReceiver = _mbtReceiver;
        shopEnabled = false;
    }

    //////////
    // public only Owner //
    //////////

    function setMbtToken(MBT _mbtToken) public onlyOwner{
        mbtToken = _mbtToken;
    }

    function setMbtReceiver(address _mbtReceiver) public onlyOwner{
        mbtReceiver = _mbtReceiver;
    }

    function setShopEnabled(bool _state) public onlyOwner {
        shopEnabled = _state;
    }

    function registerProduct(string memory productId, string memory preRequiredSoldOutProductId, IKIP17 nftContractAddress, uint256 totalAmount, uint256 mbtPrice) public onlyOwner {
        products[productId].preRequiredSoldOutProductId = preRequiredSoldOutProductId;
        products[productId].nftContractAddress = nftContractAddress;
        products[productId].mbtPrice = mbtPrice;
        products[productId].totalAmount = totalAmount;
    }

    function putNftOnProduct(string calldata productId, uint256[] calldata tokenIds) external onlyOwner {
        require(
            tokenIds.length > 0,
            "MetaBrickNftShop: tokenIds must be more than 0"
        );
        
        require(
            (products[productId].tokenIds.length + tokenIds.length) <= products[productId].totalAmount,
            "MetaBrickNftShop: can not put more than total amount"
        );


        for(uint256 i =0; i < tokenIds.length; ++i) {
            _putNftOnProduct(productId, tokenIds[i]);
        }
    }

    function takeNftOnProduct(string calldata productId) external onlyOwner {
        require(
            products[productId].tokenIds.length > 0,
            "MetaBrickNftShop: tokenIds must be more than 0"
        );

        for(uint256 i = 0; i < products[productId].tokenIds.length; ++i) {
            uint256 tokenId = products[productId].tokenIds[i];
            products[productId].nftContractAddress.safeTransferFrom(address(this), msg.sender, tokenId);
        }

        products[productId].tokenIds.length = 0;
    }

    //////////
    // extenral //
    //////////
    function purchase(string calldata productId, uint256 requestedCount) external {
        require(
            shopEnabled, "MetaBrickNftShop: shop is not enabled"
        );
        require(
            requestedCount > 0,
            "MetaBrickNftShop: requestedCount must be more than 0"
        );

        require(products[productId].tokenIds.length >= requestedCount, "MetaBrickNftShop: not enought nft to purchase");

        require(mbtToken.balanceOf(msg.sender) > products[productId].mbtPrice.mul(requestedCount),"MetaBrickNftShop: Not enough MBT");

        require(products[products[productId].preRequiredSoldOutProductId].tokenIds.length <= 0,"MetaBrickNftShop: preRequiredSoldOutProduct is not fufilled");

        for(uint256 i = 0; i < requestedCount; i++) {
            mbtToken.safeTransferFrom(msg.sender, mbtReceiver, products[productId].mbtPrice);        
            products[productId].nftContractAddress.safeTransferFrom(address(this), msg.sender, products[productId].tokenIds[0]);
            products[productId].tokenIds[0] = products[productId].tokenIds[products[productId].tokenIds.length - 1];
            delete products[productId].tokenIds[products[productId].tokenIds.length - 1];
            products[productId].tokenIds.length = products[productId].tokenIds.length.sub(1);
            products[productId].purchasedAmount = products[productId].purchasedAmount.add(1);
        }
    }
    //////////
    // View //
    //////////
    function productInfo(string memory productId)
        public
        view
        returns (string memory preRequiredSoldOutProductId,IKIP17 nftContractAddress, uint256 availableAmount,uint256 purchasedAmount, uint256 totalAmount ,uint256 mbtPrice)
    {
        return (products[productId].preRequiredSoldOutProductId, products[productId].nftContractAddress,products[productId].tokenIds.length, products[productId].purchasedAmount, products[productId].totalAmount, products[productId].mbtPrice );
    }

    /////////////
    // Internal//
    /////////////
    
    function _putNftOnProduct(string memory productId, uint256 tokenId) internal {
        require(products[productId].nftContractAddress.ownerOf(tokenId) == msg.sender, "MetaBrickNftShop: can't put nft you don't own");

        products[productId].nftContractAddress.safeTransferFrom(msg.sender, address(this), tokenId);
        products[productId].tokenIds.push(tokenId);
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
