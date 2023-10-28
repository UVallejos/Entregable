// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Enumerable is ERC721, ERC721Enumerable {

    constructor(
        string memory _collectionName,
        string memory _collectionSymbol
    ) ERC721(_collectionName, _collectionSymbol){}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qma4s6uyVSCaTouXM8N8AkAL4jc11D53Tsn1kZPs4CGd6b/";
    }

    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getNftsFromWallet(address account) public view returns(uint256[] memory result){
        uint256 tokenCount = balanceOf(account);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory tokens = new uint256[](tokenCount);
            for (uint256 i = 0; i < tokenCount; i++) {
                tokens[i] = tokenOfOwnerByIndex(account, i);
            }
            return tokens;
        }   
    }
}
