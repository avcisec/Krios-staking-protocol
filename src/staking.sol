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
error staking__UnsufficientRewardBalance();

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

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event staked(address indexed user, uint256 amountStaked);
    event RewardAdded(uint256 rewardAmount);
    event Withdrawed(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

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
        s_rewardIndex += (rewardAmount * MULTIPLIER) / s_totalSupply; // reward index = reward index + (rewardAmount * 1e18) / totalSupply
    }

    function _calculateRewards(address account) private view returns (uint256) {
        uint256 shares = balanceOf[account];
        uint256 reward = (shares * (s_rewardIndex - rewardIndexOf[account])) /
            MULTIPLIER;
        return reward;
    }

    function calculateRewardsEarned(
        address account
    ) external view returns (uint256) {
        return rewardEarned[account] + _calculateRewards(account);
    }

    function _updateRewards(address account) private {
        rewardEarned[account] += _calculateRewards(account);
        rewardIndexOf[account] = s_rewardIndex;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        _updateRewards(msg.sender);
        balanceOf[msg.sender] += amount;
        s_totalSupply += amount;
        i_stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        _updateRewards(msg.sender);
        balanceOf[msg.sender] -= amount;
        s_totalSupply -= amount;
        i_stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawed(msg.sender, amount);
    }

    function claim() external returns (uint256) {
        _updateRewards(msg.sender);
        uint256 rewardAmount = rewardEarned[msg.sender];

        if (rewardAmount > 0) {
            rewardEarned[msg.sender] = 0;
            i_rewardToken.safeTransfer(msg.sender, rewardAmount);
        } else {
            revert staking__UnsufficientRewardBalance();
        }
        emit RewardPaid(msg.sender, rewardAmount);
        return rewardAmount;
    }
}
