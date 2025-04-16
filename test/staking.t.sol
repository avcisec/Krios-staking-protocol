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
    address public tokenMinter = makeAddr("tokenMinter");
    uint256 public STARTING_BALANCE = 1 ether;
    uint256 public TOTAL_REWARD = 100 ether;

    function setUp() public {
        // Pretend stakingDeployer and deploy weth, krios, staking contract
        vm.deal(stakingDeployer, STARTING_BALANCE);
        vm.deal(alice, STARTING_BALANCE);
        vm.deal(bob, STARTING_BALANCE);
        vm.deal(tokenMinter, STARTING_BALANCE + TOTAL_REWARD);
        weth = new WETH();
        krios = new Krios();
        staking = new Staking(address(krios), address(weth));
        vm.startPrank(tokenMinter);
        krios.mint(1_000_000 * 1e18);
        weth.deposit{value: TOTAL_REWARD}();
        krios.approve(address(this), 990_000);
        weth.approve(address(this), TOTAL_REWARD);
        krios.transfer(address(staking), 990_000);
        weth.transfer(address(staking), TOTAL_REWARD);
        vm.stopPrank();
    }

    function test_Deployment() public view returns (address) {
        return address(staking);
    }

    function test_staking() public {
        vm.startPrank(tokenMinter);
        krios.transfer(alice, 100);
        vm.stopPrank();

        vm.startPrank(alice);
        krios.approve(address(staking), 100);
        staking.stake(100);
        vm.stopPrank();

        console.log("alice staking balance:", staking.getbalanceOf(alice));
        console.log("alice reward:", staking.earned(alice));
        console.log("staking contract WETH balance:", weth.balanceOf(address(staking)));
        assert(staking.getbalanceOf(alice) != 0);
    }

        function test_RewardUpdates() public {
        vm.warp(123456);
        vm.startPrank(tokenMinter);
        krios.transfer(alice, 100);
        vm.stopPrank();
        vm.deal(staking.owner(), 1 ether);
        console.log("block.timestamp:", block.timestamp);
        console.log("s_periodFinish:", staking.s_periodFinish());
        console.log("s_rewardRate:", staking.s_rewardRate());
        vm.startPrank(staking.owner());
        staking.notifyRewardAmount(weth.balanceOf(address(staking)));
        vm.stopPrank();
        console.log("staking contract reward balance", weth.balanceOf(address(staking)));
        console.log("rewardRate after:", staking.s_rewardRate());
        console.log("PeriodFinish after:", staking.s_periodFinish());
        console.log("s_rewardPerTokenStored: ", staking.s_rewardPerTokenStored());
        vm.startPrank(alice);
        krios.approve(address(staking), 100);
        staking.stake(100);
        vm.stopPrank();
        console.log("alice staking balance:", staking.getbalanceOf(alice));
        console.log("alice reward:", staking.earned(alice));
        console.log("staking contract WETH balance:", weth.balanceOf(address(staking)));
        vm.warp(block.timestamp + 3 days);
        vm.roll(block.number + 3);
        console.log("alice reward after 3 days:", staking.earned(alice));

        assert(staking.earned(alice) != 0);
    }

    function test_Unstaking() public {
        vm.startPrank(tokenMinter);
        krios.transfer(alice, 100);
        vm.stopPrank();

        vm.startPrank(alice);
        krios.approve(address(staking), 100);
        staking.stake(100);

        console.log("alice staking balance:", staking.getbalanceOf(alice));
        console.log("alice reward:", staking.earned(alice));
        console.log("staking contract WETH balance:", weth.balanceOf(address(staking)));

        staking.unstake(100);
        vm.stopPrank();
        console.log("alice staking balance after withdraw:", staking.getbalanceOf(alice));
        console.log("alice reward after withdraw:", staking.earned(alice));
        console.log("staking contract WETH balance after withdraw:", weth.balanceOf(address(staking)));
        assert(staking.getbalanceOf(alice) == 0);
    }

    function test_EarnedAmountAfter6Days() public {
        vm.startPrank(tokenMinter);
        krios.transfer(alice, 100);
        vm.stopPrank();
        vm.startPrank(alice);
        krios.approve(address(staking), 100);
        staking.stake(100);
        vm.stopPrank();
        console.log("alice staking balance:", staking.getbalanceOf(alice));
        console.log("alice reward:", staking.earned(alice));
        console.log("staking contract WETH balance:", weth.balanceOf(address(staking)));
        vm.warp(6 days);

        console.log("alice reward after 6 days:", staking.earned(alice));
        assert(staking.earned(alice) != 0);
    }

    function test_withdraw() public {
        // alice stakes 100
        vm.startPrank(tokenMinter);
        krios.transfer(alice, 100);
        vm.stopPrank();
        vm.startPrank(alice);
        krios.approve(address(staking), 100);
        staking.stake(100);
        vm.stopPrank();

        // bob also stakes 100
        vm.startPrank(tokenMinter);
        krios.transfer(bob, 100);
        vm.stopPrank();
        vm.startPrank(bob);
        krios.approve(address(staking), 100);
        staking.stake(100);
        vm.stopPrank();
        // alice withdraws
        console.log("alice staking balance:", staking.getbalanceOf(alice));
        console.log("bob staking balance:", staking.getbalanceOf(bob));
        console.log("totalsupply:", staking.getTotalSupply());
        vm.prank(alice);
        staking.unstake(100);
        vm.prank(bob);
        staking.unstake(100);
        console.log("alice staking balance after withdraw:", staking.getbalanceOf(alice));
        console.log("bob staking balance after withdraw:", staking.getbalanceOf(bob));
    }
}
