//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import {CrowdFund} from "../../src/CrowdFund.sol";
import {DeployCrowdFund} from "../../script/DeployCrowdFund.s.sol";
import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundCrowdFund, WithdrawCrowdFund} from "../../script/Interaction.s.sol";

contract InteractionTest is Test {
    CrowdFund crowdFund;

    uint256 VLAUE = 1e18 ether;
    address USER = makeAddr("chris");
    uint256 constant BALANCE = 50e18 ether;
    uint256 GAS_PRICE = 1;

    function setUp () external {
        DeployCrowdFund deployCrowdFund = new DeployCrowdFund();
        crowdFund = deployCrowdFund.run();
        vm.deal(USER, BALANCE);
    }

    function testUserCanFund() public {
        FundCrowdFund fundCrowdFund = new FundCrowdFund();
        fundCrowdFund.fundCrowdFund(address(crowdFund));

        WithdrawCrowdFund withdrawCrowdFund = new WithdrawCrowdFund();
        withdrawCrowdFund.withdrawCrowdFund(address(crowdFund));
        assert (address(crowdFund).balance == 0 );

    }
} 