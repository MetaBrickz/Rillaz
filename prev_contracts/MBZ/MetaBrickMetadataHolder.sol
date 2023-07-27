pragma solidity ^0.5.0;

import "@klaytn/contracts/access/Ownable.sol";
import "@klaytn/contracts/utils/math/SafeMath.sol";

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