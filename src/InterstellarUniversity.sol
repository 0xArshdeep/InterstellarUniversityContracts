// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721A.sol";
import "./Ownable.sol";
import "./MerkleProof.sol";
import "./Strings.sol";

contract InterstellarUniversity is ERC721A, Ownable {
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 7777;
    uint256 public constant MAX_PUBLIC_MINT = 3;
    uint256 public constant MAX_WHITELIST_MINT = 1;
    uint256 public constant PUBLIC_SALE_PRICE = .09 ether;
    uint256 public constant WHITELIST_SALE_PRICE = .05 ether;

    string private baseTokenUri;
    string public placeholderTokenUri;

    // Toggle whether the NFT is revealed or not.
    bool public isRevealed;
    // Toggle public sale active or inactive.
    bool public publicSale;
    // Toggle whiteListSale active or inactive.
    bool public whiteListSale;
    // Pause minting for IU.
    bool public pause;

    bool public teamMinted;

    bytes32 private merkleRoot;

    mapping(address => uint256) public totalPublicMint;
    mapping(address => uint256) public totalWhitelistMint;

    constructor() ERC721A("Interstellar University", "IU") {}

    /// @notice Checks to make sure that the caller is a user and is not a smart contract.
    modifier callerIsUser() {
        require(
            tx.origin == msg.sender,
            "Interstellar University :: Cannot be called by a contract."
        );
        _;
    }

    /// @notice Public mint for Interstellar University NFT. Calls _safeMint from ERC721A.
    /// @param _quantity number of tokens to mint.
    function mint(uint256 _quantity) external payable callerIsUser {
        require(
            publicSale,
            "Interstellar University :: Public Sale Is Not Yet Active."
        );
        require(
            (totalSupply() + _quantity) <= MAX_SUPPLY,
            "Interstellar University :: Beyond Max Supply"
        );
        require(
            (totalPublicMint[msg.sender] + _quantity) <= MAX_PUBLIC_MINT,
            "Interstellar University :: Already minted 3 times!"
        );
        require(
            msg.value >= (PUBLIC_SALE_PRICE * _quantity),
            "Interstellar University :: Below "
        );

        totalPublicMint[msg.sender] += _quantity;
        _safeMint(msg.sender, _quantity);
    }

    /// @notice Whitelist mint. Addresses that have been whitelisted may mint using this function.
    /// @param _merkleProof root of the MerkleProof to check for WL addresses.
    function whitelistMint(bytes32[] memory _merkleProof, uint256 _quantity)
        external
        payable
        callerIsUser
    {
        require(
            whiteListSale,
            "Interstellar University :: Minting is currently on pause."
        );
        require(
            (totalSupply() + _quantity) <= MAX_SUPPLY,
            "Interstellar University :: Cannot mint beyond the max supply."
        );
        require(
            (totalWhitelistMint[msg.sender] + _quantity) <= MAX_WHITELIST_MINT,
            "Interstellar University :: Cannot mint beyond whitelist max mint!"
        );
        require(
            msg.value >= (WHITELIST_SALE_PRICE * _quantity),
            "Interstellar University :: Payment value is below the whitelist price."
        );
        //create leaf node
        bytes32 sender = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, merkleRoot, sender),
            "Interstellar University :: You are not whitelisted."
        );

        totalWhitelistMint[msg.sender] += _quantity;
        _safeMint(msg.sender, _quantity);
    }

    function teamMint() external onlyOwner {
        require(
            !teamMinted,
            "Interstellar University :: Team has already minted."
        );
        teamMinted = true;
        _safeMint(msg.sender, 200);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenUri;
    }

    /// @notice Returns the uri for a given token id
    /// @param _tokenId The id of the token that is being looked up.
    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        uint256 trueId = _tokenId + 1;

        if (!isRevealed) {
            return placeholderTokenUri;
        }
        //string memory baseURI = _baseURI();
        return
            bytes(baseTokenUri).length > 0
                ? string(
                    abi.encodePacked(baseTokenUri, trueId.toString(), ".json")
                )
                : "";
    }

    function setTokenUri(string memory _baseTokenUri) external onlyOwner {
        baseTokenUri = _baseTokenUri;
    }

    function setPlaceHolderUri(string memory _placeholderTokenUri)
        external
        onlyOwner
    {
        placeholderTokenUri = _placeholderTokenUri;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function getMerkleRoot() external view returns (bytes32) {
        return merkleRoot;
    }

    function togglePause() external onlyOwner {
        pause = !pause;
    }

    function toggleWhiteListSale() external onlyOwner {
        whiteListSale = !whiteListSale;
    }

    function togglePublicSale() external onlyOwner {
        publicSale = !publicSale;
    }

    function toggleReveal() external onlyOwner {
        isRevealed = !isRevealed;
    }

    function withdraw() external onlyOwner {
        /// TODO
    }
}
