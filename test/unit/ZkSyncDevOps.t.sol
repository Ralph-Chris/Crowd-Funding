//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console} from "../../lib/forge-std/src/Test.sol";
import {ZkSyncChainChecker} from "../../lib/foundry-devops/src/ZkSyncChainChecker.sol";
import { FoundryZkSyncChecker} from "../../lib/foundry-devops/src/FoundryZkSyncChecker.sol";

contract ZkSyncDevOps is Test , ZkSyncChainChecker, FoundryZkSyncChecker {

    function testZkSyncChainFails() public skipZkSync {
        address ripemd = address(uint160(3));

        bool success;
        assembly {
            success := call(gas(),ripemd, 0, 0, 0, 0, 0)
        }
        assert(success);
    }

    function testZkSyncFondryFails() public onlyVanillaFoundry {
        bool exists = vm.keyExistsJson('{"hi}: "true"}', ".hi");
        assert(exists);
    }
}