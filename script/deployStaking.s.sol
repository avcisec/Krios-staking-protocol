// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {WETH} from "@solady/src/tokens/WETH.sol";
import {Krios} from "../src/utils/krios.sol";
import {Staking} from "../src/staking.sol";

contract deployStaking is Script {
    WETH public weth;
    Krios public krios;
    Staking public staking;

    function run() external returns (Staking) {
        weth = new WETH();
        krios = new Krios();
        vm.startBroadcast();
        staking = new Staking(address(krios), address(weth));
        vm.stopBroadcast();

        return staking;
    }
}
