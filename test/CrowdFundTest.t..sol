//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import {CrowdFund} from "../src/CrowdFund.sol";
import {DeployCrowdFund} from "../script/DeployCrowdFund.s.sol";
import {Test, console} from "../lib/forge-std/src/Test.sol"; 

contract CrowdFundTest is Test {
     uint256 SENDING =10e18;
     uint256 BALANCE = 50e18;
     uint256 GAS_PRICE = 1;
     event Funded (address indexed funder, uint256 amount);
    CrowdFund crowdFund;

    address USER = makeAddr("Christopher");

      modifier funding() {
        vm.prank(USER);
        crowdFund.fund{value: SENDING}();
        _;
    }

    function setUp() external {
        DeployCrowdFund deployCrowdFund = new DeployCrowdFund();
        crowdFund = deployCrowdFund.run();
        vm.deal(USER, BALANCE);
    }

    function testMinimumUsd() public {
        assertEq(crowdFund.MINIMUM_USD(), 5);
    }

    function testMsgSenderIsOwner() public {
        assertEq(crowdFund.getOwner(), msg.sender);
    }

    function testGetVersion() public {
        uint256 version = crowdFund.getVersion();
        assertEq(version, 6);
    }

    function testCrowdFundFailsWithoutEnoughEth() public {
        vm.prank(USER);
        vm.expectRevert();
        crowdFund.fund();
    }

    function testCrowdFundSendWithEnoughEth() public funding {
        uint256 amountFunded = crowdFund.s_addressToAmountFunded(USER);
        assertEq(amountFunded, SENDING);
    }

    function testaddressIsAddedToFunders() public funding {
       
        address funder = crowdFund.getFunderAddress(0);
        assertEq(funder, USER);
    }
   
    function testwithdrawWithoutOwner() public funding {
        vm.prank(USER);
        vm.expectRevert();
        crowdFund.withdraw();
    }

    function testWithdrawWithOwner() public {

        //-------Arrnage-------
        uint256 startingBalanceOfOwner = crowdFund.getOwner().balance;
        uint256 startingBalanceOfCrowdFund = address(crowdFund).balance;
        
        //-------Act-------
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(crowdFund.getOwner());
        crowdFund.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);
        
        //-------Assert-------
        uint256 endingBalanceOfOwner = crowdFund.getOwner().balance;
        uint256 endingBalanceOfContract = address(crowdFund).balance;
        assertEq(endingBalanceOfContract, 0);
        assertEq(startingBalanceOfOwner + startingBalanceOfCrowdFund, endingBalanceOfOwner);

    }

   function testWithdrawWithMultipleFunders() public funding {
    uint160 totalFunders = 10;
    uint160 startingNumberOfFunders = 1;
    for(uint160 i = startingNumberOfFunders; i < totalFunders; i++) {
        hoax(address(i), SENDING);
        crowdFund.fund{value: SENDING}();
    }

    uint256 ownerStartingBalance = crowdFund.getOwner().balance;
    uint256 crowdFundStartingBalance = address(crowdFund).balance;

    vm.startPrank(crowdFund.getOwner());
    crowdFund.withdraw();
    vm.stopPrank();

    uint256 ownerEndingBalance = crowdFund.getOwner().balance;
    uint256 crowdFundEndingBalance = address(crowdFund).balance;

    assert(address(crowdFund).balance == 0);
    assert(ownerStartingBalance + crowdFundStartingBalance
     == crowdFund.getOwner().balance);
   
   }

   function testEmitFunded() public {
    uint160 startingIndex = 1;
    uint160 endingIndex = 30;
    for (uint160 k = startingIndex; k < endingIndex; k++) {
        hoax(address(k + 1), SENDING);
        vm.expectEmit(true, false, false, true, address(crowdFund));
        emit Funded (address(k + 1), SENDING);
        crowdFund.fund{value: SENDING}();
   
    }
   
   }

}