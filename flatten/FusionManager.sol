// File: @openzeppelin\contracts\utils\Context.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin\contracts\utils\introspection\IERC165.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin\contracts\token\ERC721\IERC721.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin\contracts\token\ERC721\IERC721Receiver.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: contracts\IERC721NFTBase.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC721NFTBase {
    function safeMintWithTokenId(
        address to,
        uint256 tokenId
    ) external returns (uint256);

    function getNextTokenId() external view returns (uint256);
}

// File: contracts\FusionManager.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
contract FusionManager is Ownable, IERC721Receiver {
    struct FusionConfig {
        address nftContract1;
        address nftContract2;
        address nftContractResult;
    }

    struct FusionPerform {
        address nftContract1;
        uint256 tokenId1;
        address nftContract2;
        uint256 tokenId2;
    }

    mapping(address => bool) public eligibleNftContracts;
    mapping(bytes32 => bool) public eligibleFusions;
    mapping(bytes32 => bool) public usedFusions;
    mapping(bytes32 => address) public fusionResultContracts;

    event FusionEligibilitySet(address indexed nftContract, bool eligible);
    event FusionConfigSet(
        address indexed nftContract1,
        address indexed nftContract2,
        address nftContractResult
    );
    event FusionPerformed(
        uint256 indexed tokenId1,
        uint256 indexed tokenId2,
        uint256 tokenIdResult
    );

    // Equals to `bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IKIP17Receiver(0).onKIP17Received.selector`
    bytes4 private constant _KIP17_RECEIVED = 0x6745782b;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    function setEligibleNftContract(
        address nftContract,
        bool eligible
    ) external onlyOwner {
        eligibleNftContracts[nftContract] = eligible;
        emit FusionEligibilitySet(nftContract, eligible);
    }

    function setFusionConfig(
        address nftContract1,
        address nftContract2,
        address nftContractResult
    ) external onlyOwner {
        require(
            eligibleNftContracts[nftContract1],
            "NFT contract 1 not eligible for fusion"
        );
        require(
            eligibleNftContracts[nftContract2],
            "NFT contract 2 not eligible for fusion"
        );
        bytes32 fusionHash = getFusionHash(nftContract1, nftContract2);
        eligibleFusions[fusionHash] = true;
        fusionResultContracts[fusionHash] = nftContractResult;
        emit FusionConfigSet(nftContract1, nftContract2, nftContractResult);
    }

    function performFusion(
        address nftContract1,
        uint256 tokenId1,
        address nftContract2,
        uint256 tokenId2
    ) external {
        require(
            eligibleFusions[getFusionHash(nftContract1,nftContract2)],
            "Fusion configuration not found or not eligible"
        );

        bytes32 fusionHash = getFusionPerformHash(nftContract1, tokenId1, nftContract2, tokenId2);

        require(
            !usedFusions[fusionHash],
            "Fusion already performed with this pair of tokens"
        );
        usedFusions[fusionHash] = true;
        FusionConfig memory config = getFusionConfig(
            nftContract1,
            nftContract2
        );
        IERC721(config.nftContract1).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId1
        );
        IERC721(config.nftContract2).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId2
        );

        uint256 tokenIdResult = IERC721NFTBase(config.nftContractResult).getNextTokenId();
        IERC721NFTBase(config.nftContractResult).safeMintWithTokenId(msg.sender, tokenIdResult);

        emit FusionPerformed(
            tokenId1,
            tokenId2,
            tokenIdResult
        );
    }

    function getFusionConfig(
        address nftContract1,
        address nftContract2
    ) public view returns (FusionConfig memory) {
        bytes32 fusionHash = getFusionHash(
            nftContract1,
            nftContract2
        );
        require(
            eligibleFusions[fusionHash],
            "Fusion configuration not found or not eligible"
        );

        FusionConfig memory config;
        config.nftContract1 = nftContract1;
        config.nftContract2 = nftContract2;
        config.nftContractResult = fusionResultContracts[fusionHash];
        return config;
    }

    function getFusionHash(
        address nftContract1,
        address nftContract2
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(nftContract1, nftContract2));
    }

    function getFusionPerformHash(
        address nftContract1,
        uint256 tokenId1,
        address nftContract2,
        uint256 tokenId2
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(nftContract1, tokenId1, nftContract2, tokenId2)
            );
    }

    function transferOwnership(address newOwner) public override(Ownable) onlyOwner {
         super.transferOwnership(newOwner);
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
