// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

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

contract KlubX is ERC721A, Ownable {
    event ContractApproved(address indexed contractAddress);

    string public _baseTokenURI;
    uint256 public _totalWhitelist;
    uint256 public _itemByWallet = 1;
    bool public _canBeTransferred = true;
    mapping(address => bool) public _authorizedContracts;
    bytes32 public whitelistMerkleRoot;

    constructor(string memory baseTokenURI, uint256 totalWhitelist)
        ERC721A("KlubX", "KBX")
    {
        _baseTokenURI = baseTokenURI;
        _totalWhitelist = totalWhitelist;
    }

    function isWhitelisted(address _user, bytes32[] calldata merkleProof)
        public
        view
        returns (bool)
    {
        return
            MerkleProof.verify(
                merkleProof,
                whitelistMerkleRoot,
                keccak256(abi.encodePacked(_user))
            );
    }

    function airwhitelistdrop(
        address[] memory whitelisted,
        bytes32[][] calldata merkleProves
    ) external payable onlyOwner {
        require(
            _canBeTransferred,
            "ERC721A-KBX: Need to be in an airdrop mode"
        );
        require(
            totalSupply() + _itemByWallet <= _totalWhitelist,
            "ERC721A-KBX: Only one item per wallet"
        );
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

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override {
        require(
            from == address(0) || _authorizedContracts[from],
            "ERC721A-KBX: Non transferable token"
        );
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public payable virtual override {
        require(
            from == address(0) || _authorizedContracts[from],
            "ERC721A-KBX: Non transferable token"
        );
        safeTransferFrom(from, to, tokenId, _data);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override {
        require(
            from == address(0) || _authorizedContracts[from],
            "ERC721A-KBX: Non transferable token"
        );
        transferFrom(from, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(
            _authorizedContracts[operator],
            "ERC721A-KLBX : Operator not authorized"
        );
        setApprovalForAll(operator, approved);
    }

    function isAuthorizedContract(address contractAddress)
        public
        view
        returns (bool)
    {
        return _authorizedContracts[contractAddress];
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

    function setAuthorizedContract(address contractAddress) public onlyOwner {
        _authorizedContracts[contractAddress] = true;
        emit ContractApproved(contractAddress);
    }

    function withdrawAll() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }
}
