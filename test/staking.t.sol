// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Staking} from "../src/staking.sol";
import {Krios} from "../src/utils/krios.sol";
import {WETH} from "@solady/src/tokens/WETH.sol";

contract StakingTest is Test {
    Staking public staking;
    Krios public krios;
    WETH public weth;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public stakingDeployer = makeAddr("stakingDeployer");
    uint public STARTING_BALANCE = 1 ether;


    function setUp() public {
        // Pretend stakingDeployer and deploy weth, krios, staking contract
        hoax(stakingDeployer, STARTING_BALANCE);
        hoax(alice, STARTING_BALANCE);
        hoax(bob,STARTING_BALANCE);
        weth = new WETH();
        krios = new Krios();
        staking = new Staking(address(krios),address(weth));


    }

    function test_Deployment() public view returns (address) {
        return address(staking);
    }

    function test_staking() public {
        vm.prank(alice);
        
    }
}
