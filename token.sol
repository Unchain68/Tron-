// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract token is ERC1155 {
    
    uint256 public constant MAIN = 0;
    uint256 public constant SUB = 1;
    uint256 public constant SONGNFT = 2;
    
    mapping (uint256 => string) private _uris;

    address owner;
    address stakeContract;
    uint public test;

    constructor() public ERC1155("https://bafybeidobelazh63dhafch3yel6hjiw5rxgan7jz2oh7vc2fk2s6suielq.ipfs.dweb.link/{id}.json") {
        _mint(msg.sender, MAIN, 100, "");
        _mint(msg.sender, SUB, 100, "");
        _mint(msg.sender, SONGNFT, 1, "");
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender == owner || msg.sender == stakeContract, "Permission erR0!");
        _;
    }
    
    function uri(uint256 tokenId) override public view returns (string memory) {
        return(_uris[tokenId]);
    }
    
    function setTokenUri(uint256 tokenId, string memory uri, uint opt) public onlyOwner {
        require(bytes(_uris[tokenId]).length == 0, "Cannot set uri twice"); 
        if(opt == 1)
            _uris[tokenId] = uri;
        else
            _uris[tokenId] = string(abi.encodePacked("https://bafybeihul6zsmbzyrgmjth3ynkmchepyvyhcwecn2yxc57ppqgpvr35zsq.ipfs.dweb.link/",
        Strings.toString(tokenId),".json")); 
    }

    function setStakeContract(address _contract) public onlyOwner {
        stakeContract = _contract;
        setApprovalForAll(_contract, true);
    }

    // need onlyowner
    function minting(address _account, uint _tokenId, string memory _tokenuri) public {
        _mint(_account, _tokenId, 1, "");
        setTokenUri(_tokenId, _tokenuri,0);
    }
}
