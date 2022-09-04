//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable
{
    //_baseTokenURI for computing {tokenURI}. If set, the resulting URI for each token
    //will be the concatenation of the 'baseURI' and the 'tokenID'.

    string _baseTokenURI;

    //_price is the price of one Crypto Dev NFT
    uint256 public _price = 0.01 ether;

    //_paused is used to pause the contract in case of an emergency
    bool public _paused;

    //max number of CryptoDevs
    uint256 public maxTokenIds = 20;

    //total number of tokenIds minted
    uint256 public tokenIds;

    //Whitelist contract instance
    IWhitelist whitelist;

    //boolean to keep track of wether presale started or not
    bool public presaleStarted;

    //timestamp for when presale would end
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused{
        require(!_paused, "Contract currently paused!");
        _;
    }

    /**
    ERC721 contructor takes in a 'name' and a 'symbol' to the token collection.
    name in our case is 'CryptoDevs' and symbol is 'CD'.
    Contructor for CryptoDevs takes in the baseURI to set _baseTokenURI for the collection.
    It also initializes an instance of whitelist interface   
     */

    constructor(string memory baseURI, address whitelistContract) ERC721("Crypto Devs", "CD")
    {
       _baseTokenURI = baseURI;
       whitelist = IWhitelist(whitelistContract);
    }

    //startPresale starts presale for the whitelisted addresses
    function startPresale() public onlyOwner
    {
        presaleStarted = true;
        //Set presaleEnded time as current timestamp + 5 minutes
        //Solidity has awesome snytax for timestamps(seconds, minutes, hours, days, years)
        presaleEnded = block.timestamp + 5 minutes;
    }

    //presaleMint allows an user to mint one NFT per transaction during the presale
    function presaleMint() public payable onlyWhenNotPaused
    {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running anymore");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < maxTokenIds, "Exceeded maximum CryptoDevs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        //_safeMint is a safer version of the _mint function as it ensures that
        //if the address being minted to is a contract, then it knows how to deal with ERC721 tokens.
        //If the address being minted to is not a contract, it works the same way as mint
        _safeMint(msg.sender, tokenIds);
    }

    //mint allows a user to mint 1 NFT per transaciton after the presale has ended.
    function mint() public payable onlyWhenNotPaused
    {
        require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not ended yet");
        require(tokenIds < maxTokenIds, "Exceeded maximum CryptoDevs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    //_baseURI overrides the Openzeppelin's ERC721 implementation,
    //which by default returned an empty string for the baseURI
    function _baseURI() internal view virtual override returns (string memory)
    {
        return _baseTokenURI;
    }

    //setPaused makes the contract paused or unpaused
    function setPaused(bool val) public onlyOwner
    {
        _paused = val;
    }

    //withdraw sends all the ether in the contract
    //to the owner of the contract
    function withdraw() public onlyOwner
    {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    //function to receive Ether. msg.data must be empty
    receive() external payable{}

    //fallback function is called when msg.data is not empty
    fallback() external payable{}
}