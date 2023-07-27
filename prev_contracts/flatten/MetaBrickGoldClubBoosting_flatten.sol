
/** 
 *  SourceUnit: contracts\MetaBrickGoldClubBoosting.sol
*/
            
pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}




/** 
 *  SourceUnit: contracts\MetaBrickGoldClubBoosting.sol
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
 *  SourceUnit: contracts\MetaBrickGoldClubBoosting.sol
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
 *  SourceUnit: contracts\MetaBrickGoldClubBoosting.sol
*/
            
pragma solidity ^0.5.0;

////import "./ownership/Ownable.sol";
////import "./math/SafeMath.sol";

contract MetaBrickMetadataHolder is Ownable {

    // MetaBrickMetadata info
    struct MetaBrickMetadata {
        uint256 score;
        uint256 rarityIndex;
    }

    struct MetaBrickStakingRewards {
        uint256 rewardsPerHour; // 1MBT = 1000000000000000000
    }

    // Mapping of Token Id to MetaBrickMetadata info
    mapping(uint256 => MetaBrickMetadata) public datasPerTokenId;

    // Mapping of Rarity Index to MetaBrickStakingRewards
    mapping(uint256 => MetaBrickStakingRewards) public stakingRewardsPerRarity;

    // Constructor function
    constructor() public {
    }

    event UpdatedMetadata(address operator, uint256 tokenId, uint256 score, uint256 rarityIndex);
    function updateMetadata(uint256 tokenId, uint256 score, uint256 rarityIndex) public onlyOwner {
        datasPerTokenId[tokenId].score = score;
        datasPerTokenId[tokenId].rarityIndex = rarityIndex;
        emit UpdatedMetadata(msg.sender, tokenId, score, rarityIndex);
    }

    event UpdatedStakingRewards(address operator, uint256 rarityIndex, uint256 rewardsPerHour);
    function updateStakingRewards(uint256 rarityIndex, uint256 rewardsPerHour) public onlyOwner {
        stakingRewardsPerRarity[rarityIndex].rewardsPerHour = rewardsPerHour;
        emit UpdatedStakingRewards(msg.sender, rarityIndex, rewardsPerHour);
    }

    //////////
    // View //
    //////////

    function getMetadata(uint256 tokenId) public view returns (uint256[2] memory) {

        uint256[2] memory metadata =
        [
          datasPerTokenId[tokenId].score, 
          datasPerTokenId[tokenId].rarityIndex 
        ];

        return metadata;
    }

    function getStakingRewards(uint256 rarityIndex) public view returns (uint256) {
        return stakingRewardsPerRarity[rarityIndex].rewardsPerHour;
    }
}



/** 
 *  SourceUnit: contracts\MetaBrickGoldClubBoosting.sol
*/
            
pragma solidity ^0.5.0;

library String {

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
    if (_i == 0) {
      return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
      bstr[k--] = byte(uint8(48 + _i % 10));
      _i /= 10;
    }
    return string(bstr);
  }

}




/** 
 *  SourceUnit: contracts\MetaBrickGoldClubBoosting.sol
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
 *  SourceUnit: contracts\MetaBrickGoldClubBoosting.sol
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
 *  SourceUnit: contracts\MetaBrickGoldClubBoosting.sol
*/
            
pragma solidity ^0.5.0;

////import "./token/KIP17/IKIP17.sol";
////import "./token/KIP7/IKIP7.sol";
////import "./ownership/Ownable.sol";
////import "./utils/String.sol";
////import "./math/SafeMath.sol";
////import "./MetaBrickMetaDataHolder.sol";

contract MetaBrickStaking is Ownable {
    using SafeMath for uint256;
    IKIP17 public nftCollection;
    IKIP7 public rewardsToken;
    MetaBrickMetadataHolder public metadataHolder;

    // Staker info
    struct Staker {
        uint256 amountStaked; // 스테이킹 된 토큰 총합
        uint256[] tokenIds; // 스테이킹 된 토큰 리스트
    }

    // Mapping of User Address to Staker info
    mapping(address => Staker) public stakers;
    // Mapping of Token Id to staker. Made for the SC to remeber
    // who to send back the ERC721 Token to.
    mapping(uint256 => address) public stakerAddress;

    mapping(uint256 => uint256) public lastUpdateTimePerTokenId; //
    mapping(uint256 => uint256) public rewardPerTokenId;

    bool public stakingEnabled = false;

    // Equals to `bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IKIP17Receiver(0).onKIP17Received.selector`
    bytes4 private constant _KIP17_RECEIVED = 0x6745782b;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Constructor function
    constructor(
        IKIP17 _nftCollection,
        IKIP7 _rewardsToken,
        MetaBrickMetadataHolder _metadataHolder
    ) public {
        nftCollection = _nftCollection;
        rewardsToken = _rewardsToken;
        metadataHolder = _metadataHolder;
        stakingEnabled = false;
    }

    //////////
    // public only Owner //
    //////////

    function setNftCollection(IKIP17 _nftCollection) public onlyOwner {
        nftCollection = _nftCollection;
    }

    function setRewardsToken(IKIP7 _rewardsToken) public onlyOwner {
        rewardsToken = _rewardsToken;
    }

    function setMetadataHolder(MetaBrickMetadataHolder _metadataHolder) public onlyOwner
    {
        metadataHolder = _metadataHolder;
    }

    function setStakingEnabled(bool _state) public onlyOwner {
        stakingEnabled = _state;
    }   


    //////////
    // extenral //
    //////////

    function stake(uint256[] calldata _tokenIds) external {
        require(stakingEnabled, "MetaBrickzStaking:  staking is not enabled");
        require(_tokenIds.length > 0, "MetaBrickzStaking: _tokenIds must be more than 0");

        for (uint256 i; i < _tokenIds.length; ++i) {
            uint256 tokenId = _tokenIds[i];
            require(
                nftCollection.ownerOf(tokenId) == msg.sender,
                "MetaBrickzStaking: Can't stake tokens you don't own!"
            );
            nftCollection.safeTransferFrom(msg.sender, address(this), tokenId);

            stakerAddress[tokenId] = msg.sender;

            stakers[msg.sender].amountStaked = stakers[msg.sender]
                .amountStaked
                .add(1);
            stakers[msg.sender].tokenIds.push(tokenId);
            lastUpdateTimePerTokenId[tokenId] = block.timestamp;
            rewardPerTokenId[tokenId] = calculateRewards(tokenId);
        }
    }

    function claimRewards(uint256[] calldata _tokenIds) external {
        require(_tokenIds.length > 0, "MetaBrickzStaking: _tokenIds must be more than 0");
        for (uint256 i; i < _tokenIds.length; ++i) {
            uint256 tokenId = _tokenIds[i];
            claimReward(tokenId);
        }
    }

    function withdraw(uint256[] calldata _tokenIds) external {
        require(_tokenIds.length > 0, "MetaBrickzStaking:  _tokenIds must be more than 0");

        for (uint256 i; i < _tokenIds.length; ++i) {
            uint256 tokenId = _tokenIds[i];
            address tokenOwner = stakerAddress[tokenId];

            require(
                tokenOwner == msg.sender || msg.sender == this.owner(),
                "MetaBrickzStaking: Can't witdraw unless you own the tokens or owner of this contract!"
            );

            claimReward(tokenId);

            if (stakers[tokenOwner].tokenIds.length > 1) {
                uint256 tokenIdx = getTokenIndex(tokenId);
                require(
                    stakers[tokenOwner].tokenIds[tokenIdx] == tokenId,
                    "MetaBrickzStaking: Not a valid Tokend Index for given TokenId !"
                );

                stakers[tokenOwner].tokenIds[tokenIdx] = stakers[tokenOwner].tokenIds[stakers[tokenOwner].tokenIds.length - 1];
                delete stakers[tokenOwner].tokenIds[stakers[tokenOwner].tokenIds.length - 1];

            } else {
                delete stakers[tokenOwner].tokenIds[0];
            }

            stakers[tokenOwner].tokenIds.length = stakers[tokenOwner]
                    .tokenIds
                    .length
                    .sub(1);

            nftCollection.safeTransferFrom(address(this), tokenOwner, tokenId);

            stakers[tokenOwner].amountStaked = stakers[tokenOwner]
                .amountStaked
                .sub(1);

            stakerAddress[tokenId] = address(0);
            lastUpdateTimePerTokenId[tokenId] = 0;
            rewardPerTokenId[tokenId] = 0;
        }
    }

    //////////
    // View //
    //////////

    function userStakeInfo(address _user)
        public
        view
        returns (uint256 _tokensStaked, uint256 _availableRewards)
    {
        return (stakers[_user].amountStaked, availableRewards(_user));
    }

    function availableRewards(address _user) internal view returns (uint256) {
        uint256 _rewards = 0;

        for (uint256 i; i < stakers[_user].tokenIds.length; ++i) {
            _rewards = _rewards.add(
                calculateRewards(stakers[_user].tokenIds[i])
            );
        }

        return _rewards;
    }

    function tokenOfStakerByIndex(address _user, uint256 index)
        public
        view
        returns (uint256)
    {
        require(
            index < stakers[_user].amountStaked,
            "MetaBrickzStaking: owner index out of bounds"
        );
        return stakers[_user].tokenIds[index];
    }

    function availableRewardsPerToken(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        uint256 _rewards;
        _rewards = rewardPerTokenId[tokenId] + calculateRewards(tokenId);
        return _rewards;
    }

    /////////////
    // Internal//
    /////////////

    function calculateRewards(uint256 tokenId)
        internal
        view
        returns (uint256 _rewards)
    {
        uint256[2] memory metadata = metadataHolder.getMetadata(tokenId);
        uint256 rewardsPerHour = metadataHolder.getStakingRewards(metadata[1]);

        return (((block.timestamp - lastUpdateTimePerTokenId[tokenId]) *
            rewardsPerHour) / 3600);
    }

    function claimReward(uint256 tokenId) internal {
        require(
            stakerAddress[tokenId] != address(0),
            "MetaBrickzStaking: Can't claim reward from token not Staked!"
        );

        uint256 rewards = calculateRewards(tokenId).add(
            rewardPerTokenId[tokenId]
        );
        if (rewards > 0) {
            lastUpdateTimePerTokenId[tokenId] = block.timestamp;
            rewardPerTokenId[tokenId] = 0;
            rewardsToken.safeTransferFrom(
                this.owner(),
                stakerAddress[tokenId],
                rewards
            );
        }
    }

    function getTokenIndex(uint256 tokenId)
        internal
        view
        returns (uint256 _index)
    {
        require(
            stakerAddress[tokenId] != address(0),
            "MetaBrickzStaking: Can't get TokenIndex from token not Staked!"
        );

        address tokenOwner = stakerAddress[tokenId];

        _index = 0;

        for (uint256 i = 0; i < stakers[tokenOwner].tokenIds.length; i++) {
            if (stakers[tokenOwner].tokenIds[i] == tokenId) {
                _index = i;
                return _index;
            }
        }

        return _index;
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


/** 
 *  SourceUnit: contracts\MetaBrickGoldClubBoosting.sol
*/

pragma solidity ^0.5.0;

////import "./token/KIP17/IKIP17.sol";
////import "./token/KIP7/IKIP7.sol";
////import "./ownership/Ownable.sol";
////import "./utils/String.sol";
////import "./math/SafeMath.sol";
////import "./MetaBrickMetaDataHolder.sol";
////import "./MetaBrickStaking.sol";

contract MetaBrickGoldClubBoosting is Ownable {
    using SafeMath for uint256;
    IKIP17 public goldclub;
    IKIP7 public rewardsToken;
    MetaBrickMetadataHolder public metadataHolder;
    MetaBrickStaking public staking;

    // Booster info
    struct Booster {
        uint256 amountBoosted; // 부스팅 된 토큰 총합
        uint256[] tokenIds; // 부스팅 된 토큰 리스트
    }

    // Mapping of User Address to Staker info
    mapping(address => Booster) public boosters;
    mapping(uint256 => address) public boosterAddress;
    mapping(uint256 => uint256) public lastUpdateTimePerTokenId;
    mapping(uint256 => uint256) public boostStartTimePerTokenId;
    mapping(uint256 => uint256) public claimedRewardPerTokenId;

    bool public boostingEnabled = false;
    uint256 public minBoostingTime = 24 * 60 * 60;
    uint256 public maxBoostingTime = 24 * 60 * 60;

    uint256 public rewardMultiplier = 5; //
    uint256 public rewardMultiplierDecimal = 1; //

    // Equals to `bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IKIP17Receiver(0).onKIP17Received.selector`
    bytes4 private constant _KIP17_RECEIVED = 0x6745782b;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Constructor function
    constructor(
        IKIP17 _goldClub,
        IKIP7 _rewardsToken,
        MetaBrickMetadataHolder _metadataHolder,
        MetaBrickStaking _staking
    ) public {
        goldclub = _goldClub;
        rewardsToken = _rewardsToken;
        metadataHolder = _metadataHolder;
        staking = _staking;
        boostingEnabled = false;
    }

    //////////
    // public only Owner //
    //////////
    function setGoldClub(IKIP17 _goldClub) public onlyOwner {
        goldclub = _goldClub;
    }

    function setRewardsToken(IKIP7 _rewardsToken) public onlyOwner {
        rewardsToken = _rewardsToken;
    }

    function setMetadataHolder(MetaBrickMetadataHolder _metadataHolder)
        public
        onlyOwner
    {
        metadataHolder = _metadataHolder;
    }

    function setStaking(MetaBrickStaking _staking) public onlyOwner {
        staking = _staking;
    }

    function setBoostingEnabled(bool _state) public onlyOwner {
        boostingEnabled = _state;
    }

    function setBoostingTime(uint256 _minBoostingTime, uint256 _maxBoostingTime)
        public
        onlyOwner
    {
        require(
            _minBoostingTime > 0,
            "MetaBrickGoldClubBoosting: _minBoostingTime must be more than 0"
        );
        require(
            _maxBoostingTime > 0,
            "MetaBrickGoldClubBoosting: _maxBoostingTime must be more than 0"
        );

        minBoostingTime = _minBoostingTime;
        maxBoostingTime = _maxBoostingTime;
    }

    function setRewardMultiplier(uint256 _multiplier, uint256 _decimal)
        public
        onlyOwner
    {
        require(
            _multiplier > 0,
            "MetaBrickGoldClubBoosting: _multiplier must be more than 0"
        );

        rewardMultiplier = _multiplier;
        rewardMultiplierDecimal = _decimal;
    }

    //////////
    // extenral //
    //////////
    function boost(uint256 _tokenId, uint256 _boosterId) external {
        require(
            boostingEnabled,
            "MetaBrickGoldClubBoosting: Boosting is not enabled"
        );
        require(
            goldclub.ownerOf(_boosterId) == msg.sender,
            "MetaBrickGoldClubBoosting: Can't boost tokens you don't own!"
        );
        require(
            staking.stakerAddress(_tokenId) == msg.sender,
            "MetaBrickGoldClubBoosting: Can't boost tokens you don't stake!"
        );

        if (boostStartTimePerTokenId[_tokenId] > 0) {
            require(
                calculateReward(_tokenId) == 0,
                "MetaBrickGoldClubBoosting: Can't boost tokens with on-going boost"
            );
        }

        //burn token
        goldclub.safeTransferFrom(msg.sender, 0x9b31b34fd6Ed831Cc8D3898f960249b9aC83A1B9, _boosterId);

        boosterAddress[_tokenId] = msg.sender;
        boosters[msg.sender].amountBoosted = boosters[msg.sender]
            .amountBoosted
            .add(1);
        boosters[msg.sender].tokenIds.push(_tokenId);

        lastUpdateTimePerTokenId[_tokenId] = block.timestamp;
        boostStartTimePerTokenId[_tokenId] = block.timestamp;
        claimedRewardPerTokenId[_tokenId] = 0;
    }

    function claimReward(uint256 _tokenId) external {
        require(
            staking.stakerAddress(_tokenId) == msg.sender,
            "MetaBrickGoldClubBoosting: Can't claim boost tokens you don't stake!"
        );

        require(
            boosterAddress[_tokenId] == msg.sender,
            "MetaBrickGoldClubBoosting: Can't claim boost tokens you don't boost"
        );

        uint256 reward = calculateReward(_tokenId);

        if (reward > 0) {
            lastUpdateTimePerTokenId[_tokenId] = block.timestamp;
            claimedRewardPerTokenId[_tokenId] = claimedRewardPerTokenId[
                _tokenId
            ].add(reward);
            rewardsToken.safeTransferFrom(
                this.owner(),
                boosterAddress[_tokenId],
                reward
            );
        }
    }

    //////////
    // View //
    //////////
    function userBoostInfo(address _user)
        public
        view
        returns (uint256 _tokenBoosted, uint256 _availableRewards)
    {
        return (boosters[_user].amountBoosted, availableRewards(_user));
    }

    function availableRewards(address _user) internal view returns (uint256) {
        uint256 _rewards = 0;

        for (uint256 i; i < boosters[_user].tokenIds.length; ++i) {
            uint256 tokenId = boosters[_user].tokenIds[i];
            _rewards = _rewards.add(calculateReward(tokenId));
        }

        return _rewards;
    }

    function tokenOfUserByIndex(address _user, uint256 index)
        public
        view
        returns (uint256)
    {
        require(
            index < boosters[_user].amountBoosted,
            "MetaBrickGoldClubBoosting: owner index out of bounds"
        );
        return boosters[_user].tokenIds[index];
    }

    function availableRewardsPerToken(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        uint256 _rewards;
        _rewards = calculateReward(tokenId);
        return _rewards;
    }

    /////////////
    // Internal//
    /////////////
    function calculateReward(uint256 tokenId)
        internal
        view
        returns (uint256 _rewards)
    {
        uint256[2] memory metadata = metadataHolder.getMetadata(tokenId);

        uint256 rewardMultiplierDevider = 1;

        for (uint256 i = 0; i < rewardMultiplierDecimal; i++) {
            rewardMultiplierDevider *= 10;
        }

        uint256 rewardPerHour = metadataHolder.getStakingRewards(metadata[1]);

        rewardPerHour =
            (rewardPerHour * rewardMultiplier) /
            rewardMultiplierDevider;

        uint256 reward = ((block.timestamp -
            lastUpdateTimePerTokenId[tokenId]) * rewardPerHour) / 3600;

        uint256 maxReward = (maxBoostingTime * rewardPerHour) / 3600;

        if (maxReward > reward.add(claimedRewardPerTokenId[tokenId])) {
            return reward;
        } else return maxReward.sub(claimedRewardPerTokenId[tokenId]);
    }

    function getTokenIndex(uint256 tokenId)
        internal
        view
        returns (uint256 _index)
    {
        require(
            boosterAddress[tokenId] != address(0),
            "MetaBrickGoldClubBoosting: Can't get TokenIndex from token not Staked!"
        );

        address tokenOwner = boosterAddress[tokenId];

        _index = 0;

        for (uint256 i = 0; i < boosters[tokenOwner].tokenIds.length; i++) {
            if (boosters[tokenOwner].tokenIds[i] == tokenId) {
                _index = i;
                return _index;
            }
        }

        return _index;
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