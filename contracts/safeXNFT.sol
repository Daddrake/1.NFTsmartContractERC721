// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract safeXNFT is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    struct Client{
        uint256 id;
        uint256 support_level;
    }
    
    mapping(uint256 => Client) public tokenIdToClients;

    constructor() ERC721("safeX secure business integration", "SBI"){}

    function generateCharacter(uint256 tokenId) public view returns(string memory){
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: purple; font-family: serif; font-size: 18px; }</style>',
            '<rect width="100%" height="100%" fill="gray" />',
            '<text x="50%" y="20%" class="base" dominant-baseline="middle" text-anchor="middle">safeX</text>',
            getStats(tokenId), '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

    function getLevel(uint256 tokenId) public view returns(string memory){
        uint256 levels = tokenIdToClients[tokenId].support_level;
        return levels.toString();
    }

    function getStats(uint256 tokenID) public view returns(string memory){
        string memory res = string(
            abi.encodePacked(
                '<text x="20%" y="30%" class="base" dominant-baseline="left" text-anchor="left">ID: ', tokenIdToClients[tokenID].id.toString(), '</text>',
                '<text x="20%" y="40%" class="base" dominant-baseline="left" text-anchor="left">Level: ', tokenIdToClients[tokenID].support_level.toString(),'</text>'
        ));
        return res;
    }
        
    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory attributes = abi.encodePacked(
            '[{"trait_type": "Program", "value": "Function"},',
            '{"trait_type": "Function", "value": "Signature and Verification"},',
            '{"trait_type": "Token standard", "value": "ERC721"},',
            '{"trait_type": "Support level", "value": "', getLevel(tokenId), '"}]'
        );
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"description": "safeX NFT for support subscription",',
                '"image": "', generateCharacter(tokenId), '",',
                '"name": "safeX #', tokenId.toString(), '",',
                '"attributes":', attributes,
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
    
    function mint() public {
        _tokenIds.increment();
        uint256 tokenid = _tokenIds.current();
        _safeMint(msg.sender, tokenid);
        tokenIdToClients[tokenid].id = tokenid;
        tokenIdToClients[tokenid].support_level = 0; 
        _setTokenURI(tokenid, getTokenURI(tokenid));
    }

    function setSupportLevel(uint256 tokenId, uint256 supLevel) public {
        require(_exists(tokenId), "Please usdescriptione an existing token");
        tokenIdToClients[tokenId].support_level = supLevel;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

}