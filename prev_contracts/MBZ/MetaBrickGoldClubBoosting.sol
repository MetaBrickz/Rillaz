pragma solidity ^0.5.0;

import "@klaytn/contracts/KIP/token/KIP17/IKIP17.sol";
import "@klaytn/contracts/KIP/token/KIP7/IKIP7.sol";
import "@klaytn/contracts/access/Ownable.sol";
import "@klaytn/contracts/utils/String.sol";
import "@klaytn/contracts/utils/math/SafeMath.sol";
import "./MetaBrickMetaDataHolder.sol";
import "./MetaBrickStaking.sol";

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
