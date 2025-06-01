// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract NotaryService {
    address private immutable i_owner;
    mapping(bytes32 fileHash => address[] signerAddress) private notaryRecords;
    uint256 public constant FIXED_FEE = 0.5 ether;

    constructor() {
        i_owner = msg.sender;
    }

    event FileNotarized(
        bytes32 indexed fileHash,
        address indexed signerAddress
    );

    function notarizeFile(bytes32 fileHash) public payable {
        address sender = msg.sender; // Gas saved :)

        require(msg.value == FIXED_FEE, "NotaryService: Incorrect fee amount");

        notaryRecords[fileHash].push(sender);
        emit FileNotarized(fileHash, sender);
    }

    function isFileSignedbyUser(
        bytes32 fileHash,
        address user
    ) public view returns (bool) {
        address[] memory signers = notaryRecords[fileHash];
        for (uint256 i = 0; i < signers.length; i++) {
            if (signers[i] == user) {
                return true;
            }
        }
        return false;
    }

    function getSigners(
        bytes32 fileHash
    ) public view returns (address[] memory) {
        return notaryRecords[fileHash];
    }

    function withdrawFee() public onlyOwner {
        payable(i_owner).transfer(address(this).balance);
    }

    modifier onlyOwner() {
        require(
            msg.sender == i_owner,
            "NotaryService: Caller is not the owner"
        );
        _;
    }
}
