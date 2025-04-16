// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {WETH} from "@solady/src/tokens/WETH.sol";
import {Krios} from "../src/utils/krios.sol";
import {Staking} from "../src/staking.sol";
import {HelperConfig} from "./helperConfig.s.sol";


contract deployStaking is Script {

    Staking public staking;

    function run() external returns (Staking) {
        // weth = new WETH();
        // krios = new Krios();
    HelperConfig helperConfig = new HelperConfig();
    (address weth, address krios) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        staking = new Staking(krios, weth);
        vm.stopBroadcast();
        return staking;
    }
}
