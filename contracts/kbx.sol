// SPDX-License-Identifier: MIT
// BY DAVZER FOR KLUBX
//               ,--,
//        ,--.,---.'|
//    ,--/  /||   | :                    ,---,. ,--,     ,--,
// ,---,': / ':   : |            ,--,  ,'  .'  \|'. \   / .`|
// :   : '/ / |   ' :          ,'_ /|,---.' .' |; \ `\ /' / ;
// |   '   ,  ;   ; '     .--. |  | :|   |  |: |`. \  /  / .'
// '   |  /   '   | |__ ,'_ /| :  . |:   :  :  / \  \/  / ./
// |   ;  ;   |   | :.'||  ' | |  . .:   |    ;   \  \.'  /
// :   '   \  '   :    ;|  | ' |  | ||   :     \   \  ;  ;
// |   |    ' |   |  ./ :  | | :  ' ;|   |   . |  / \  \  \
// '   : |.  \;   : ;   |  ; ' |  | ''   :  '; | ;  /\  \  \
// |   | '_\.'|   ,/    :  | : ;  ; ||   |  | ;./__;  \  ;  \
// '   : |    '---'     '  :  `--'   \   :   / |   : / \  \  ;
// ;   |,'              :  ,      .-./   | ,'  ;   |/   \  ' |
// '---'                 `--`----'   `----'    `---'     `--`

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "https://github.com/ProjectOpenSea/operator-filter-registry/blob/529cceeda9f5f8e28812c20042cc57626f784718/src/DefaultOperatorFilterer.sol";
import "https://github.com/chiru-labs/ERC721A/blob/2342b592d990a7710faf40fe66cfa1ce61dd2339/contracts/ERC721A.sol";


contract KlubX is ERC721A, DefaultOperatorFilterer, Ownable {
    string public _baseTokenURI;
    uint256 public _totalWhitelist;
    uint256 public _itemByWallet = 1;
    bool public _canBeTransferred = true;
    mapping(address => bool) public _authorizedContracts;
    bytes32 public whitelistMerkleRoot;

    constructor(string memory baseTokenURI, uint256 totalWhitelist) ERC721A("KlubX", "KBX")
    {
        _baseTokenURI = baseTokenURI;
        _totalWhitelist = totalWhitelist;
    }

    function isWhitelisted(address _user, bytes32[] calldata merkleProof) public view returns (bool) {
        return MerkleProof.verify(merkleProof, whitelistMerkleRoot, keccak256(abi.encodePacked(_user)));
    }

    function airwhitelistdrop(address[] memory whitelisted, bytes32[][] calldata merkleProves) external payable onlyOwner {
        require(_canBeTransferred, "ERC721A-KBX: Need to be in an airdrop mode");
        require(totalSupply() + _itemByWallet <= _totalWhitelist, "ERC721A-KBX: Only one item per wallet");

        for (uint256 a = 0; a < whitelisted.length; a++) {
            if (
                numberMinted(whitelisted[a]) + _itemByWallet <= _itemByWallet &&
                isWhitelisted(whitelisted[a], merkleProves[a])
            ) {
                _safeMint(whitelisted[a], _itemByWallet);
            }
        }
    }

    // ** OVERRIDE //

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function _beforeTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity) internal virtual override {
        require(_canBeTransferred || _authorizedContracts[from], "ERC721A-KBX: Non transferable token");
        super._beforeTokenTransfers(from, to, startTokenId, quantity);
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    // OWNER

    function setTransfeable(bool canBeTransferred) public onlyOwner {
        _canBeTransferred = canBeTransferred;
    }

    function setTotalWhitelist(uint256 totalWhitelist) public onlyOwner {
        _totalWhitelist = totalWhitelist;
    }

    function setWhitelistUsers(bytes32 merkleRoot) external onlyOwner {
        whitelistMerkleRoot = merkleRoot;
    }

    function setAuthorizedContract(address contractAddress) public onlyOwner {
        _authorizedContracts[contractAddress] = true;
    }

    // WITHDRAW

    function withdrawAll() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    /////////////////////////////
    // OPENSEA FILTER REGISTRY 
    /////////////////////////////

    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        require(_canBeTransferred || _authorizedContracts[operator], "ERC721A-KLBX : Operator not authorized"); // Additional check on top of OpenSea
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public payable override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public payable override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}
