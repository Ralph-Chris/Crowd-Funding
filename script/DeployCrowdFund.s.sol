//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {CrowdFund} from "../src/CrowdFund.sol";

contract DeployCrowdFund is Script {
    function run() external returns (CrowdFund) {
        HelperConfig helperConfig = new HelperConfig();
        address  networkConfig = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        CrowdFund crowdFund = new CrowdFund(networkConfig);
        vm.stopBroadcast();
        return crowdFund;

    }
} 