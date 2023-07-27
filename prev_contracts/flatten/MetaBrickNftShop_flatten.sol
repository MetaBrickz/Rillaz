
/** 
 *  SourceUnit: contracts\MetaBrickNftShop.sol
*/
            
pragma solidity ^0.5.0;

/**
 * @dev Interface of the KIP-13 standard, as defined in the
 * [KIP-13](http://kips.klaytn.com/KIPs/kip-13-interface_query_standard).
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others.
 *
 * For an implementation, see `KIP13`.
 */
interface IKIP13 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [KIP-13 section](http://kips.klaytn.com/KIPs/kip-13-interface_query_standard#how-interface-identifiers-are-defined)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}




/** 
 *  SourceUnit: contracts\MetaBrickNftShop.sol
*/
            
pragma solidity ^0.5.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface IKIP7Receiver {
    function onKIP7Received(address _operator, address _from, uint256 _amount, bytes calldata _data) external returns (bytes4);
}

contract MBT {
    using SafeMath for uint256;
    using Address for address;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    address private _owner;

    string private _name;
    string private _symbol;
    uint8 private _decimals = 18;
    uint256 private _totalSupply;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (bytes4 => bool) private _supportedInterfaces;

    bytes4 private _KIP7_RECEIVED = 0x9d188c22;
    bytes4 private constant _INTERFACE_ID_KIP13 = 0x01ffc9a7;
    bytes4 private constant _INTERFACE_ID_KIP7 = 0x65787371;
    bytes4 private constant _INTERFACE_ID_KIP7_METADATA = 0xa219a025;
    bytes4 private constant _INTERFACE_ID_KIP7BURNABLE = 0x3b5a0bf8;

    // ======== mining ========
    address public distributor;
    uint256 public lastMined;
    uint256 public minableBlock;

    uint256 public blockAmount;

    uint256 public halfLife;
    uint256 public halving;
    uint256 public miningAmount;

    constructor(
        string memory name, // 이름
        string memory symbol, // 심볼
        uint256 _minableBlock, // 최소 블록 하이트
        uint256 _blockAmount, // 블록당 마이닝수 1MBT = 1000000000000000000
        uint256 _halfLife, // 반감기 설정
        uint256 _halving, // 반감기 설정
        uint256 _miningAmount, // 최대 마이닝수 1MBT = 1000000000000000000 
        address initialSupplyClaimer, // 최초 발행 물량 받을 주소
        uint256 initialSupply // 최초 물량 금액 1MBT = 1000000000000000000
    ) public {
        _registerInterface(_INTERFACE_ID_KIP13);
        _registerInterface(_INTERFACE_ID_KIP7);
        _registerInterface(_INTERFACE_ID_KIP7_METADATA);
        _registerInterface(_INTERFACE_ID_KIP7BURNABLE);

        _owner = msg.sender;
        _name = name;
        _symbol = symbol;

        require(_minableBlock > block.number);
        minableBlock = _minableBlock;

        require(_blockAmount != 0);
        blockAmount = _blockAmount;

        halfLife = _halfLife;
        halving = _halving;
        miningAmount = _miningAmount;

        if(initialSupplyClaimer != address(0) && initialSupply != 0)
            _mint(initialSupplyClaimer, initialSupply);
    }

    function version() public pure returns (string memory) {
        return "MKC220120";
    }

    ///////////////////////// ownable /////////////////////////
    modifier onlyOwner {
        require(msg.sender == _owner);
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    event SetDistributor(address indexed previousDistributor, address indexed newDistributor);
    function setDistributor(address _distributor) public onlyOwner {
        require(_distributor != address(0));
        emit SetDistributor(distributor, _distributor);
        distributor = _distributor;
    }
    ///////////////////////////////////////////////////////////

    ///////////////////////// mining /////////////////////////
    function mined() public view returns (uint256 res) {
        uint256 endBlock = block.number;
        uint256 startBlock = minableBlock;
        if (endBlock < startBlock) return 0;

        uint blockAmt = blockAmount;

        if(halfLife != 0){
            uint256 level = ((endBlock.sub(startBlock)).add(1)).div(halfLife);
            if(halving != 0) level = level > halving ? halving : level;

            for(uint256 i = 0; i < level; i++){
                if(startBlock.add(halfLife) > endBlock) break;

                res = res.add(blockAmt.mul(halfLife));
                startBlock = startBlock.add(halfLife);
                blockAmt = blockAmt.div(2);
            }
        }

        res = res.add(blockAmt.mul((endBlock.sub(startBlock)).add(1)));
        if(miningAmount != 0) res = res > miningAmount ? miningAmount : res;
    }

    modifier onlyDistributor {
        require(msg.sender == distributor);
        _;
    }

    event Mine(uint256 thisMined, uint256 lastMined, uint256 curMined);
    function mine() public onlyDistributor {
        uint256 curMined = mined(); 
        uint256 thisMined = curMined.sub(lastMined);
        if(thisMined == 0) return;

        emit Mine(thisMined, lastMined, curMined);

        lastMined = curMined;
        _mint(distributor, thisMined);
    }
    //////////////////////////////////////////////////////////

    ////////////////////// KIP7 Standard //////////////////////
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function safeTransfer(address recipient, uint256 amount) public {
        safeTransfer(recipient, amount, "");
    }

    function safeTransfer(address recipient, uint256 amount, bytes memory data) public {
        transfer(recipient, amount);
        require(_checkOnKIP7Received(msg.sender, recipient, amount, data), "KIP7: transfer to non KIP7Receiver implementer");
    }

    function safeTransferFrom(address sender, address recipient, uint256 amount) public {
        safeTransferFrom(sender, recipient, amount, "");
    }

    function safeTransferFrom(address sender, address recipient, uint256 amount, bytes memory data) public {
        transferFrom(sender, recipient, amount);
        require(_checkOnKIP7Received(sender, recipient, amount, data), "KIP7: transfer to non KIP7Receiver implementer");
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "KIP7: transfer from the zero address");
        require(recipient != address(0), "KIP7: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "KIP7: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "KIP7: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner_, address spender, uint256 value) internal {
        require(owner_ != address(0), "KIP7: approve from the zero address");
        require(spender != address(0), "KIP7: approve to the zero address");

        _allowances[owner_][spender] = value;
        emit Approval(owner_, spender, value);
    }

    function _checkOnKIP7Received(address sender, address recipient, uint256 amount, bytes memory _data)
        internal returns (bool)
    {
        if (!recipient.isContract()) {
            return true;
        }

        bytes4 retval = IKIP7Receiver(recipient).onKIP7Received(msg.sender, sender, amount, _data);
        return (retval == _KIP7_RECEIVED);
    }

    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "KIP13: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    ///////////////////////////////////////////////////////////
}




/** 
 *  SourceUnit: contracts\MetaBrickNftShop.sol
*/
            
pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address payable private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address payable) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




/** 
 *  SourceUnit: contracts\MetaBrickNftShop.sol
*/
            
pragma solidity ^0.5.0;

////import "../../introspection/IKIP13.sol";

/**
 * @dev Interface of the KIP7 standard as defined in the KIP. Does not include
 * the optional functions; to access them see `KIP7Metadata`.
 * See http://kips.klaytn.com/KIPs/kip-7-fungible_token
 */
contract IKIP7 is IKIP13 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
    * @dev Moves `amount` tokens from the caller's account to `recipient`.
    */
    function safeTransfer(address recipient, uint256 amount, bytes memory data) public;

    /**
    * @dev  Moves `amount` tokens from the caller's account to `recipient`.
    */
    function safeTransfer(address recipient, uint256 amount) public;

    /**
    * @dev Moves `amount` tokens from `sender` to `recipient` using the allowance mechanism.
    * `amount` is then deducted from the caller's allowance.
    */
    function safeTransferFrom(address sender, address recipient, uint256 amount, bytes memory data) public;

    /**
    * @dev Moves `amount` tokens from `sender` to `recipient` using the allowance mechanism.
    * `amount` is then deducted from the caller's allowance.
    */
    function safeTransferFrom(address sender, address recipient, uint256 amount) public;

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




/** 
 *  SourceUnit: contracts\MetaBrickNftShop.sol
*/
            
pragma solidity ^0.5.0;

////import "../../introspection/IKIP13.sol";

/**
 * @dev Required interface of an KIP17 compliant contract.
 */
contract IKIP17 is IKIP13 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either `approve` or `setApproveForAll`.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either `approve` or `setApproveForAll`.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}


/** 
 *  SourceUnit: contracts\MetaBrickNftShop.sol
*/

pragma solidity ^0.5.0;

////import "./token/KIP17/IKIP17.sol";
////import "./token/KIP7/IKIP7.sol";
////import "./ownership/Ownable.sol";
////import "./KIP-7.sol";

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