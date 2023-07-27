pragma solidity ^0.8.0;

import "@klaytn/contracts/KIP/token/KIP17/KIP17.sol";
import "@klaytn/contracts/KIP/token/KIP17/extensions/KIP17Enumerable.sol";
import "@klaytn/contracts/KIP/token/KIP17/extensions/KIP17Mintable.sol";
import "@klaytn/contracts/KIP/token/KIP17/extensions/KIP17Burnable.sol";
import "@klaytn/contracts/KIP/token/KIP17/extensions/KIP17Pausable.sol";
import "@klaytn/contracts/utils/math/SafeMath.sol";
import "@klaytn/contracts/utils/Strings.sol";
import "@klaytn/contracts/access/Ownable.sol";

contract KIP17MetaFunkyRillaz is 
KIP17,
KIP17Mintable,
KIP17Enumerable, 
KIP17Burnable, 
KIP17Pausable,   
Ownable 
{
  using SafeMath for uint256;
  using Address for address;

    // To prevent bot attack, we record the last contract call block number.
    mapping (address => uint256) private _lastCallBlockNumber;

    // If someone burns NFT in the middle of minting,
    // the tokenId will go wrong, so use the index instead of totalSupply().
    uint256 private _mintIndexForSale;
    uint256 private _maxSaleAmount;               // Maximum purchase volume of normal sale.

    string baseURI;

    constructor (string memory name, string memory symbol) KIP17(name, symbol)  
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());

      //init explicitly.
      _mintIndexForSale = 1;
      _maxSaleAmount = 10000;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(KIP17, KIP17Mintable, KIP17Enumerable, KIP17Burnable, KIP17Pausable) returns (bool) {
      return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(KIP17, KIP17Enumerable, KIP17Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
       


    function _baseURI() internal view virtual override(KIP17) returns (string memory)  {
      return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyRole(MINTER_ROLE) {
      baseURI = _newBaseURI;
    }

    function tokenURI(uint256 tokenId)
      public
      view
      virtual override(KIP17)
      returns (string memory)
    {
      require(
        _exists(tokenId),
        "KIP17MetaFunkyRillaz: URI query for nonexistent token"
      );
      
      string memory currentBaseURI = _baseURI();
      return bytes(currentBaseURI).length > 0
          ? string(abi.encodePacked(currentBaseURI, "?tokenId=" ,Strings.toString(tokenId)))
          : "";
    }

    function withdraw() external onlyRole(MINTER_ROLE) {
      // This will transfer the remaining contract balance to the owner.
      // Do not remove this otherwise you will not be able to withdraw the funds.
      // =============================================================================
      payable(msg.sender).transfer(address(this).balance);
      // =============================================================================
    }

    function mintingInformation() external view returns (uint256[2] memory){
      uint256[2] memory info =
        [
          _mintIndexForSale, 
          _maxSaleAmount
        ];
      return info;
    }

    function setupSale(uint256 newMintIndexForSale,
                       uint256 newMaxSaleAmount) external onlyRole(MINTER_ROLE) {
      _mintIndexForSale = newMintIndexForSale;
      _maxSaleAmount = newMaxSaleAmount;
    }

    function safeMint(address to, uint256 requestedCount) external onlyRole(MINTER_ROLE) {
      require(_mintIndexForSale.sub(1).add(requestedCount) <= _maxSaleAmount, "Exceed max amount");

      for(uint256 i = 0; i < requestedCount; i++) {        
        _mint(to, _mintIndexForSale);
        _mintIndexForSale = _mintIndexForSale.add(1);
      }

      _lastCallBlockNumber[msg.sender] = block.number;
    }
}