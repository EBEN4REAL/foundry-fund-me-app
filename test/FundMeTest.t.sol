// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    uint256 number = 1;
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 10e18 => 1 * 10^18 10^-1;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    // First function that runs when the test is executed
    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testMsgIsOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVerionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // The next line should revert
        // uint256 cat = 1;  // test expect this line to fail but it passed so the test fails
        fundMe.fund(); // This fails as expected because I didnt send any value so the test passes
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // it's used to simulate a transaction from a specific address.
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        // assertEq(amountFunded, 10e18);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _; // proceeds to run whatever test is using the funded modifier via _
    }

    function testOnlyOwnerCanWithdraw() public funded {
        console.log("OWNER ADDR => 66", fundMe.getOwner());
        console.log("Test funding ADDR => 67", USER);
        vm.prank(USER); // Simulates msg.sender = USER
        vm.expectRevert(); // Tell Foundry to expect the next call to fail (revert)
        fundMe.withdraw(); // Try to withdraw (should fail, USER is not the owner)
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance; // Converts the fundMe contract instance into its Ethereum address and Gets the ETH balance of that address.

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); // should have spent gas?
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // tx.gasprice is built into solidity
 
        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance // + gasUsed
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10; // uint160 is the exact size of an Ethereum address (160 bits), so casting to address(i) is valid
        uint160 startingFunderIndex = 1; // using index 0 is not advisable in test because sometimwes the operations are reverted and solidity does not let the operatin go through
        // address(0) is a special, reserved address that no one controls
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank  new address
            // vm.deal new address => send eth to address
            // address
            hoax(address(i), SEND_VALUE); // pranks the new address and deal the new address combined
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundedBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingFundedBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
}
