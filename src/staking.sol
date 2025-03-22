// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

// to do
// her fonksiyon icin natspec yaz
// lock period entegre edilecek

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

/*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
/*                         Imports                            */
/*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

import {Ownable} from "@openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

/**
 *
 *
 * @title Krios Staking
 * @author 0xavcieth
 *
 * @notice This contract is a staking contract to earn WETH with Krios Token
 * @dev Implementation of Synthetix Staking Algorithm
 */
contract Staking is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          Errors                            */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    error Staking__AmountCanNotBeZero();
    error Staking__StakingDepositFailed();
    error Staking__StakingWithdrawFailed();
    error Staking__RewardClaimFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          Interfaces                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    IERC20 public immutable i_stakingToken; // token to be staked
    IERC20 public immutable i_rewardToken; // token to be rewarded

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          State Variables                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    mapping(address => uint256) private _balances; // user's stakingToken balance
    mapping(address => uint256) public userRewardPerTokenPaid; // Formüldeki P değeri
    mapping(address => uint256) public rewards; //
    uint256 public s_rewardRate = 100;
    // saniyede kazılan ödül miktarı formüldeki R değeri
    uint256 public s_lastUpdateTime; // kontratın son çağrılma zamanı
    uint256 public s_rewardPerTokenStored; //  matematik formülündeki S değeri
    uint256 public s_rewardDuration = 7 days;
    uint256 public s_periodFinish = 0;
    // Earned = s_rewardPerTokenStored - userRewardPerTokenPaid[user]
    uint256 private constant MULTIPLIER = 1e18; // precision için 18 basamak ekliyoruz
    uint256 private _totalSupply; // total number of token staked in this contract

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         Events                             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    event tokenStaked(address indexed user, uint256 amountStaked);
    event tokenWithdrawn(address indexed user, uint256 amountWithdrawn);
    event rewardClaimed(address indexed user, uint256 ClaimedRewardAmount);
    event rewardRateUpdated(uint256 NewRewardRate);

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          Modifiers                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    modifier notZero(uint256 amount) {
        if (amount == 0) {
            revert Staking__AmountCanNotBeZero();
        }
        _;
    }

    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    constructor(address _stakingToken, address _rewardToken) Ownable(msg.sender) {
        i_stakingToken = IERC20(_stakingToken);
        i_rewardToken = IERC20(_rewardToken);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        Public Functions                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/


    /**
     * @notice This function updates amount of reward token to be paid out per second.
     * @notice Only owner of this contract can change reward rate.
     * @param _rewardRate Amount of reward tokens to be paid out per second.
     */
    function updateRewardRate(uint256 _rewardRate) public notZero(_rewardRate) onlyOwner {
        s_rewardRate = _rewardRate;
        emit rewardRateUpdated(_rewardRate);
    }



    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        External Functions                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/


    /**
     * @notice This function allows user to stake their tokens in this contract.
     * @param amount Amount of tokens to be staked.
     */
    function stake(uint256 amount) external nonReentrant notZero(amount) updateReward(msg.sender) {
        _totalSupply += amount;
        _balances[msg.sender] += amount;
        emit tokenStaked(msg.sender, amount);
        bool success = IERC20(i_stakingToken).transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert Staking__StakingDepositFailed();
        }
    }


    /**
     * @notice This function allows user to withdraw their staked tokens from this contract.
     * @param amount Amount of tokens to be withdrawn.
     */
    function unstake(uint256 amount) external nonReentrant notZero(amount) updateReward(msg.sender) {
        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        emit tokenWithdrawn(msg.sender, amount);
        bool success = IERC20(i_stakingToken).transfer(msg.sender, amount);
        if (!success) {
            revert Staking__StakingWithdrawFailed();
        }
    }


    /**
     * @notice This function allows user to claim their earned reward tokens from this contract.
     */
    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        emit rewardClaimed(msg.sender, reward);
        bool success = IERC20(i_rewardToken).transferFrom(address(this), msg.sender, reward);
        if (!success) {
            revert Staking__RewardClaimFailed();
        }
        i_rewardToken.safeTransferFrom(address(this), msg.sender, reward);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  Public & External view Functions          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/


    /**
     * @notice This function calculates reward per token.
     * @return Amount of reward tokens to be paid out per token.
     */
    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return 0;
        }

        return
            s_rewardPerTokenStored + (s_rewardRate * (block.timestamp - s_lastUpdateTime) * MULTIPLIER / _totalSupply);
    }

    /**
     * @notice This function calculates amount of reward tokens earned by user.
     * @param account Address of user.
     * @return Amount of reward tokens earned by user.
     */

    function earned(address account) public view returns (uint256) {
        return
            (_balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / MULTIPLIER) + rewards[account];
    } // tüm formül


    /**
     * @notice This function returns amount of staked tokens by user.
     * @param account Address of user.
     * @return Amount of staked tokens by user.
     */

    function getbalanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @notice This function returns total amount of staked tokens in this contract.
     * @return Total amount of staked tokens in this contract.
     */
    function getTotalSupply() public view returns (uint256) {
        return _totalSupply;
    }
}
