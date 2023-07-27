pragma solidity ^0.5.0;

import "@klaytn/contracts/KIP/token/KIP17/KIP17.sol";
import "@klaytn/contracts/KIP/token/KIP17/KIP17Token.sol";
import "./roles/MinterRole.sol";
import "@klaytn/contracts/utils/math/SafeMath.sol";
import "@klaytn/contracts/utils/String.sol";
import "./MerkleProof.sol";

contract KIP17MetaFunkyBrick is KIP17, MinterRole {

    // To prevent bot attack, we record the last contract call block number.
    mapping (address => uint256) private _lastCallBlockNumber;
    uint256 private _antibotInterval;

    // If someone burns NFT in the middle of minting,
    // the tokenId will go wrong, so use the index instead of totalSupply().
    uint256 private _mintIndexForSale;

    uint256 private _mintLimitPerBlock;           // Maximum purchase nft per person per block
    uint256 private _mintLimitPerSale;            // Maximum purchase nft per person per sale

    string  private _tokenBaseURI;
    uint256 private _mintStartBlockNumber;        // In blockchain, blocknumber is the standard of time.
    uint256 private _maxSaleAmount;               // Maximum purchase volume of normal sale.
    uint256 private _mintPrice;                   // 1 KLAY = 1000000000000000000
    uint256 private _whitelistMintPrice;          // 1 KLAY = 1000000000000000000

    uint256 private _maxTokenId;                  // Maximum Token ID 
    mapping(uint256 => uint256) private _shuffleTokenIdList;
    uint256 private _shuffleStart;
    uint256 private _shuffleRemaining;

    string baseURI;

    bool public publicMintEnabled = false;

    //Whitelist Mint
    bytes32 public merkleRoot;
    mapping(address => uint256) public whitelistClaimedCount;
    

    bool public whitelistMintEnabled = false;

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

    function mintingInformation() external view returns (uint256[7] memory){
      uint256[7] memory info =
        [
          _antibotInterval, 
          _mintIndexForSale, 
          _mintLimitPerBlock, 
          _mintStartBlockNumber, 
          _maxSaleAmount, 
          _mintPrice,
          _whitelistMintPrice
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
                       uint256 newMaxTokenId,
                       uint256 newMintPrice,
                       uint256 newWhitelistMintPrice) external onlyMinter{
      _antibotInterval = newAntibotInterval;
      _mintLimitPerBlock = newMintLimitPerBlock;
      _mintStartBlockNumber = newMintStartBlockNumber;
      _mintIndexForSale = newMintIndexForSale;
      _maxSaleAmount = newMaxSaleAmount;
      _mintPrice = newMintPrice;
      _whitelistMintPrice = newWhitelistMintPrice;
      _maxTokenId = newMaxTokenId;

      _shuffleStart = _mintIndexForSale;
      _shuffleRemaining = _maxTokenId - _shuffleStart.sub(1);
    }

    //Public Mint
    function publicMint(uint256 requestedCount) external payable {
      require(publicMintEnabled, "The public sale is not enabled!");
      require(_lastCallBlockNumber[msg.sender].add(_antibotInterval) < block.number, "Bot is not allowed");
      require(block.number >= _mintStartBlockNumber, "Not yet started");
      require(requestedCount > 0 && requestedCount <= _mintLimitPerBlock, "Too many requests or zero request");
      require(msg.value == _mintPrice.mul(requestedCount), "Not enough Klay");
      require(_mintIndexForSale.sub(1).add(requestedCount) <= _maxSaleAmount, "Exceed max amount");

      for(uint256 i = 0; i < requestedCount; i++) {        
        uint256 tokenId = drawTokenIdFromSuffle();      
        _mint(msg.sender, tokenId);
        _mintIndexForSale = _mintIndexForSale.add(1);
      }

      _lastCallBlockNumber[msg.sender] = block.number;
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyMinter {
      merkleRoot = _merkleRoot;
    }

    function setWhitelistMintEnabled(bool _state) public onlyMinter {
      whitelistMintEnabled = _state;
    }

    function whitelistMint(uint256 requestedCount, bytes32[] calldata _merkleProof) external payable {
      require(whitelistMintEnabled, "The whitelist sale is not enabled!");
       require(_lastCallBlockNumber[msg.sender].add(_antibotInterval) < block.number, "Bot is not allowed");
      require(msg.value == _whitelistMintPrice.mul(requestedCount), "Not enough Klay");
      require(requestedCount > 0 && requestedCount <= _mintLimitPerBlock, "Too many requests or zero request");

      bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
      require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'Invalid proof!');

      require(_mintIndexForSale.sub(1).add(requestedCount) <= _maxSaleAmount, "Exceed max amount");

      for(uint256 i = 0; i < requestedCount; i++) {  
        uint256 tokenId = drawTokenIdFromSuffle();      
        _mint(msg.sender, tokenId);
        _mintIndexForSale = _mintIndexForSale.add(1);
      }

      _lastCallBlockNumber[msg.sender] = block.number;

      uint256 claimedCount = whitelistClaimedCount[msg.sender];
      whitelistClaimedCount[msg.sender] = claimedCount.add(requestedCount);
    }

    //Airdrop Mint
    function airDropMint(address user, uint256 startIndex , uint256 requestedCount) external onlyMinter {
      require(startIndex > 0, "none zero index");
      require(requestedCount > 0, "zero request");
      require(startIndex.sub(1).add(requestedCount) <= _maxSaleAmount, "Exceed max amount");
      
      for(uint256 i = 0; i < requestedCount; i++) {
        if(!_exists(startIndex)) {
          _mint(user, startIndex);
        }
        startIndex = startIndex.add(1);
      }
    }

    function drawTokenIdFromSuffle() internal returns (uint256 tokenId) {
      uint256 i = uint(blockhash(block.number - 1)) % _shuffleRemaining;

      tokenId = _shuffleTokenIdList[i] == 0 ? (_shuffleStart.add(i)) : _shuffleTokenIdList[i];
      require(!_exists(tokenId), "Brickz: token already minted!");

      _shuffleTokenIdList[i] = _shuffleTokenIdList[_shuffleRemaining.sub(1)] == 0 ? _shuffleStart.add( _shuffleRemaining.sub(1)) : _shuffleTokenIdList[_shuffleRemaining.sub(1)];
      _shuffleRemaining = _shuffleRemaining.sub(1);
    }
}

contract KIP17MetaFunkyBrickToken is KIP17Token, KIP17MetaFunkyBrick {
    constructor (string memory name, string memory symbol) public KIP17Token(name, symbol) {
    }
}