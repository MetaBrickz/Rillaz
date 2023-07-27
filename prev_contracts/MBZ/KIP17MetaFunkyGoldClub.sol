pragma solidity ^0.5.0;

import "@klaytn/contracts/KIP/token/KIP17/KIP17.sol";
import "@klaytn/contracts/KIP/token/KIP17/KIP17Token.sol";
import "./roles/MinterRole.sol";
import "./roles/MinterRole.sol";
import "@klaytn/contracts/utils/math/SafeMath.sol";
import "@klaytn/contracts/utils/String.sol";
import "./MerkleProof.sol";

contract KIP17MetaFunkyGoldClub is KIP17, MinterRole {

    // To prevent bot attack, we record the last contract call block number.
    mapping (address => uint256) private _lastCallBlockNumber;
    uint256 private _antibotInterval;

    // If someone burns NFT in the middle of minting,
    // the tokenId will go wrong, so use the index instead of totalSupply().
    uint256 private _mintIndexForSale;
    uint256 private _mintLimitPerBlock;           // Maximum purchase nft per person per block

    string  private _tokenBaseURI;
    uint256 private _mintStartBlockNumber;        // In blockchain, blocknumber is the standard of time.
    uint256 private _maxSaleAmount;               // Maximum purchase volume of normal sale.
    uint256 private _mintPrice;                   // 1 KLAY = 1000000000000000000

    string baseURI;
    // string notRevealedUri;
    // bool public revealed = false;
    bool public publicMintEnabled = false;

    function _baseURI() internal view returns (string memory) {
      return baseURI;
    }
    function setBaseURI(string memory _newBaseURI) public onlyMinter {
      baseURI = _newBaseURI;
    }

    function tokenURI(uint256 tokenId)
      public
      view
      returns (string memory)
    {
      require(
        _exists(tokenId),
        "KIP17Metadata: URI query for nonexistent token"
      );
      
      string memory currentBaseURI = _baseURI();
      return bytes(currentBaseURI).length > 0
          ? string(abi.encodePacked(currentBaseURI, String.uint2str(tokenId), ".json"))
          : "";
    }

    constructor () public {
      //init explicitly.
      _mintIndexForSale = 1;
    }

    function withdraw() external onlyMinter{
      // This will transfer the remaining contract balance to the owner.
      // Do not remove this otherwise you will not be able to withdraw the funds.
      // =============================================================================
      msg.sender.transfer(address(this).balance);
      // =============================================================================
    }

    function mintingInformation() external view returns (uint256[6] memory){
      uint256[6] memory info =
        [
          _antibotInterval, 
          _mintIndexForSale, 
          _mintLimitPerBlock,
          _mintStartBlockNumber, 
          _maxSaleAmount, 
          _mintPrice
        ];
      return info;
    }

    function setPublicMintEnabled(bool _state) public onlyMinter {
      publicMintEnabled = _state;
    }

    function setupSale(uint256 newAntibotInterval, 
                       uint256 newMintLimitPerBlock,
                       uint256 newMintStartBlockNumber,
                       uint256 newMintIndexForSale,
                       uint256 newMaxSaleAmount,
                       uint256 newMintPrice) external onlyMinter{
      _antibotInterval = newAntibotInterval;
      _mintLimitPerBlock = newMintLimitPerBlock;
      _mintStartBlockNumber = newMintStartBlockNumber;
      _mintIndexForSale = newMintIndexForSale;
      _maxSaleAmount = newMaxSaleAmount;
      _mintPrice = newMintPrice;
    }

    //Public Mint
    function publicMint(uint256 requestedCount) external payable {
      require(publicMintEnabled, "The public sale is not enabled!");
      require(_lastCallBlockNumber[msg.sender].add(_antibotInterval) < block.number, "Bot is not allowed");
      require(block.number >= _mintStartBlockNumber, "Not yet started");
      require(requestedCount > 0 && requestedCount <= _mintLimitPerBlock, "Too many requests or zero request");
      require(msg.value == _mintPrice.mul(requestedCount), "Not enough Klay");
      require(_mintIndexForSale.add(requestedCount) <= _maxSaleAmount, "Exceed max amount");

      for(uint256 i = 0; i < requestedCount; i++) {        
        _mint(msg.sender, _mintIndexForSale);
        _mintIndexForSale = _mintIndexForSale.add(1);
      }
      _lastCallBlockNumber[msg.sender] = block.number;
    }

    //Airdrop Mint
    function airDropMint(address user, uint256 requestedCount) external onlyMinter {
      require(requestedCount > 0, "zero request");
      for(uint256 i = 0; i < requestedCount; i++) {
        uint256 tokenId = _mintIndexForSale;
        _mint(user, tokenId);
        _mintIndexForSale = _mintIndexForSale.add(1);
      }
    }
}

contract KIP17MetaFunkyGoldClubToken is KIP17Token, KIP17MetaFunkyGoldClub {
    constructor (string memory name, string memory symbol) public KIP17Token(name, symbol) {
    }
}