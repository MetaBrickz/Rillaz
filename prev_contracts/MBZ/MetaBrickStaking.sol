pragma solidity ^0.5.0;

import "@klaytn/contracts/KIP/token/KIP17/IKIP17.sol";
import "@klaytn/contracts/KIP/token/KIP7/IKIP7.sol";
import "@klaytn/contracts/access/Ownable.sol";
import "@klaytn/contracts/utils/String.sol";
import "@klaytn/contracts/utils/math/SafeMath.sol";
import "./MetaBrickMetaDataHolder.sol";

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
