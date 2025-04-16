// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Krios} from "../src/utils/krios.sol";

contract deployStaking is Script {
    Krios public krios;

    function run() external returns (Krios) {
        vm.startBroadcast();
        krios = new Krios();
        vm.stopBroadcast();
        return krios;
    }
}
