// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;

//imports
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DaviesNFT is ERC721, Ownable {
    uint256 public mintPrice;
    uint256 public totalMinting;
    uint256 public maxSupply;
    uint256 public maxPerWallet;
    bool public isMintEnabled;
    string internal baseTokenUri;
    address payable public withdrawWallet;
    mapping(address => uint256) public walletToNumMints;

    constructor() payable ERC721("DaviesNFT", "DV") {
        mintPrice = 0.02 ether;
        totalMinting = 0;
        maxSupply = 1000;
        maxPerWallet = 2;
        // withdrawWallet = ??
    }

    function setIsMintEnabled(bool isMintEnabled_) external onlyOwner {
        isMintEnabled = isMintEnabled_;
    }

    function setBaseTokenUri(string calldata baseTokenUri_) external onlyOwner {
        baseTokenUri = baseTokenUri_;
    }

    function tokenURI(uint256 tokenId_)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId_), "Token does not exist!");
        return
            string(
                abi.encodePacked(
                    baseTokenUri,
                    Strings.toString(tokenId_),
                    ".json"
                )
            );
    }

    //withdraw function
    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWallet.call{value: address(this).balance}(
            ""
        );
        require(success, "withdraw failed");
    }

    //mint function
    function mint(uint256 quantity_) public payable {
        require(isMintEnabled, "Minting not enabled");
        require(msg.value == quantity_ * mintPrice, "Not enough ETH");
        require(totalMinting + quantity_ <= maxSupply, "sold out");
        require(
            walletToNumMints[msg.sender] + quantity_ <= maxPerWallet,
            "You own too many"
        );

        for (uint256 i = 0; i < quantity_; i++) {
            uint256 newTokenId = totalMinting + 1;
            totalMinting++;
            _safeMint(msg.sender, newTokenId);
        }
    }
}
