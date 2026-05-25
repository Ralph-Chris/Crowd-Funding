//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {CrowdFund} from "../src/CrowdFund.sol";

contract FundCrowdFund is Script {
    uint256 constant SENDING_VALUE = 0.1 ether;

    function fundCrowdFund(address latestAddress) public {
        vm.startBroadcast();
        CrowdFund(payable(latestAddress)).fund{value: SENDING_VALUE}();
        vm.stopBroadcast();
    }

    function run() external {
        address latestAddress = DevOpsTools.get_most_recent_deployment("CrowdFund", block.chainid);
        vm.startBroadcast();
        fundCrowdFund(latestAddress);
        vm.stopBroadcast();
    }
}

contract WithdrawCrowdFund is Script {
    function withdrawCrowdFund(address latestAddress) public {
        vm.startBroadcast();
        CrowdFund(payable(latestAddress)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address latestAddress = DevOpsTools.get_most_recent_deployment("CrowdFund", block.chainid);
        vm.startBroadcast();
        withdrawCrowdFund(latestAddress);
        vm.stopBroadcast();
    }
}
