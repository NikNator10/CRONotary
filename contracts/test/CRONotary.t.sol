// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {NotaryService} from "../src/CRONotary.sol";

contract CRONotaryTest is Test {
    NotaryService public notary;
    event FileNotarized(bytes32 indexed fileHash, address indexed signer);

    address public constant OWNER = address(1);
    address public constant USER = address(2);

    bytes32 public constant FILE_HASH = keccak256("File content");

    uint256 public constant STARTING_BALANCE = 1 ether;
    uint256 public FIXED_FEE;

    function setUp() external {
        vm.startPrank(OWNER); // Without this, the contract will be deployed by CRONotaryTest
        notary = new NotaryService();
        vm.stopPrank();

        FIXED_FEE = notary.getFixedFee();

        vm.deal(OWNER, STARTING_BALANCE);
        vm.deal(USER, STARTING_BALANCE);
    }

    function testRevertIfUserWithdrawsFee() external {
        vm.expectRevert();
        vm.startPrank(USER);
        notary.withdrawFee();
        vm.stopPrank();
    }

    function testNotarizeFile() external {
        vm.startPrank(USER);
        notary.notarizeFile{value: FIXED_FEE}(FILE_HASH);
        vm.stopPrank();

        address[] memory signers = notary.getSigners(FILE_HASH);

        assertEq(signers.length, 1);
        assertEq(signers[0], USER);
        assertEq(USER.balance, STARTING_BALANCE - FIXED_FEE);
        assertEq(address(notary).balance, FIXED_FEE);
        assertTrue(notary.isFileSignedbyUser(FILE_HASH, USER));
    }

    function testMultipleSignersForSameFile() external {
        address SECOND_USER = address(3);
        vm.deal(SECOND_USER, STARTING_BALANCE);

        vm.startPrank(USER);
        notary.notarizeFile{value: FIXED_FEE}(FILE_HASH);
        vm.stopPrank();

        vm.startPrank(SECOND_USER);
        notary.notarizeFile{value: FIXED_FEE}(FILE_HASH);
        vm.stopPrank();

        address[] memory signers = notary.getSigners(FILE_HASH);
        
        assertEq(signers.length, 2);
        assertEq(signers[0], USER);
        assertEq(signers[1], SECOND_USER);
    }

    function testDuplicateNotarizationFromOneUser() external {
        vm.startPrank(USER);
        notary.notarizeFile{value: FIXED_FEE}(FILE_HASH);
        vm.stopPrank();

        vm.startPrank(USER);
        notary.notarizeFile{value: FIXED_FEE}(FILE_HASH);
        vm.stopPrank();

        address[] memory signers = notary.getSigners(FILE_HASH);

        assertEq(signers.length, 2);

        assertEq(signers[0], USER);
        assertEq(signers[1], USER);

        assertEq(USER.balance, STARTING_BALANCE - 2* FIXED_FEE);
        assertEq(address(notary).balance, 2* FIXED_FEE);
    
    }

    function testWithdrawFeeAsOwner() external {
        vm.startPrank(USER);
        notary.notarizeFile{value: FIXED_FEE}(FILE_HASH);
        vm.stopPrank();

        vm.startPrank(OWNER);
        notary.withdrawFee();
        vm.stopPrank();

        assertEq(address(notary).balance, 0 ether);
        assertEq(OWNER.balance, STARTING_BALANCE + FIXED_FEE);
        
    }

    function testEventEmittedOnNotarization() external {
        vm.expectEmit(true, true, false,false);
        emit FileNotarized(FILE_HASH, USER);

        vm.startPrank(USER);
        notary.notarizeFile{value: FIXED_FEE}(FILE_HASH);
        vm.stopPrank();
    }
}
