// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

/*//////////////////////////////////////////////////////////////
                                IMPORTS
//////////////////////////////////////////////////////////////*/

import {Ownable} from "@openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

/*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

contract staking is Ownable {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                               INTERFACES
    //////////////////////////////////////////////////////////////*/

    IERC20 public immutable i_stakingToken;
    IERC20 public immutable i_rewardToken;

    /*//////////////////////////////////////////////////////////////
                                MAPPINGS
    //////////////////////////////////////////////////////////////*/

    mapping(address => uint256) public balanceOf; // user's stakingToken balance
    mapping(address => uint256) private rewardIndexOf; // mapping for reward index of an address
    mapping(address => uint256) private rewardEarned; // earned reward amount of address

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    uint256 public s_totalSupply; // total supply of staked token
    uint256 private s_rewardIndex;
    uint256 private constant MULTIPLIER = 1e18;

    constructor(
        address _stakingToken,
        address _rewardToken
    ) Ownable(msg.sender) {
        i_stakingToken = IERC20(_stakingToken);
        i_rewardToken = IERC20(_rewardToken);
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function updateRewardIndex(uint256 rewardAmount) external {
        i_rewardToken.safeTransferFrom(msg.sender, address(this), rewardAmount);
        s_rewardIndex += (rewardAmount * MULTIPLIER) / s_totalSupply;
    }

    function _calculateRewardEarned(
        address account
    ) private view returns (uint256) {
        uint256 shares = balanceOf[account];
        uint256 reward = (shares * (s_rewardIndex - rewardIndexOf[account])) /
            MULTIPLIER;
    }
}
