// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(msg.sender);
	DeployFundMe deployFundMe = new DeployFundMe();
	fundMe = deployFundMe.run();
	vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
	assertEq(fundMe.MIN_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
	assertEq(fundMe.getOwner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() public {
	uint256 version = fundMe.getVersion();
	assertEq(version, 4);
    }

    function testFundFailWithoutEnoughETH() public {
        vm.expectRevert();
	// assert(This tx fails/reverts)
	fundMe.fund(); 
    }

    function testFundUpdateFundedDataStructure() public {
	vm.prank(USER);
        fundMe.fund{value: 10e18}();

	uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
	assertEq(amountFunded, 10e18);

    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
	fundMe.fund{value: 10e18}();

	address funder = fundMe.getFunder(0);
	assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
	fundMe.fund{value: 10e18}();
	_;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
	vm.expectRevert();
	fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
	uint256 startingOwnerBalance = fundMe.getOwner().balance;
	uint256 startingFundMeBalance = address(fundMe).balance;

	// Act
	vm.prank(fundMe.getOwner());
	fundMe.withdraw();

	// Assert
	uint256 endingOwnerBalance = fundMe.getOwner().balance;
	uint256 endingFundMeBalance = address(fundMe).balance;
	assertEq(endingFundMeBalance, 0);
	assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
	// Arrange
        uint160 numberOfFunders = 10;
	uint160 startingFunderIndex = 1;
	for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
	    // vm.prank new address
	    // vm.deal new address
	    //address()
	    hoax(address(i), 10e18);
	    fundMe.fund{value: 10e18}();
	    // fund the fundMe
	}

	uint256 startingOwnerBalance = fundMe.getOwner().balance;
	uint256 startingFundMeBalance = address(fundMe).balance;

	// Act
	vm.startPrank(fundMe.getOwner());
	fundMe.withdraw();
	vm.stopPrank();

	// Assert
	assert(address(fundMe).balance == 0);
	assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
	// Arrange
	uint160 numberOfFunders = 10;
	uint160 startingFunderIndex = 1;
	for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
	    // vm.prank new address
	    // vm.deal new address
	    //address()
	    hoax(address(i), 10e18);
	    fundMe.fund{value: 10e18}();
	}
	uint256 startingOwnerBalance = fundMe.getOwner().balance;
	uint256 startingFundMeBalance = address(fundMe).balance;
        // Act
	vm.startPrank(fundMe.getOwner());
	fundMe.cheaperWithdraw();
	vm.stopPrank();

        // Assert
	assert(address(fundMe).balance == 0);
	assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testDemo() public {}
}

// us -> FundMeTest -> FundMe
