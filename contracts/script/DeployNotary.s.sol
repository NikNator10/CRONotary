// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {NotaryService} from "../src/CRONotary.sol";

contract DeployNotary is Script {
    function run() external {
        vm.startBroadcast();
        NotaryService notary = new NotaryService();
        vm.stopBroadcast();
        console.log("NotaryService deployed at:", address(notary));
    }
}
