// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {WETH} from "@solady/src/tokens/WETH.sol";
import {Krios} from "../src/utils/krios.sol";
import {Staking} from "../src/staking.sol";

contract HelperConfig is Script {

    struct NetworkConfig {
        address weth;
        address krios;
    }

    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant LOCAL_CHAIN_ID = 31337;

    NetworkConfig public activeNetworkConfig;

    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        if (block.chainid == ETH_SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
        
    }

        function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
            return NetworkConfig({
                weth: 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9,
                krios: 0x469774163ae2FB104305457a208EE2a898E5B18e
            });
        }


        function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory) {
            vm.startBroadcast();
            WETH weth = new WETH();
            Krios krios = new Krios();
            vm.stopBroadcast();

            return NetworkConfig({
                weth: address(weth),
                krios: address(krios)
            });
        }
}

