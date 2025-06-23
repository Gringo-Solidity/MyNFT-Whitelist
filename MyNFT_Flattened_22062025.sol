// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MyNFT is ERC721, Ownable {
    uint256 public nextTokenId = 1;
    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant MINT_PRICE = 0.01 ether;

    bytes32 public merkleRoot; // Для whitelist
    bool public whitelistMintEnabled = false;

    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}

    function whitelistMint(bytes32[] calldata proof) external payable {
        require(whitelistMintEnabled, "Whitelist mint disabled");
        require(msg.value >= MINT_PRICE, "Insufficient ETH");
        require(nextTokenId <= MAX_SUPPLY, "Max supply reached");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Not whitelisted");

        _mint(msg.sender, nextTokenId);
        nextTokenId++;
    }

    function mint() external payable {
        require(msg.value >= MINT_PRICE, "Insufficient ETH");
        require(nextTokenId <= MAX_SUPPLY, "Max supply reached");

        _mint(msg.sender, nextTokenId);
        nextTokenId++;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function toggleWhitelistMint() external onlyOwner {
        whitelistMintEnabled = !whitelistMintEnabled;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
