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

contract Staking is Ownable {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                               INTERFACES
    //////////////////////////////////////////////////////////////*/

    IERC20 public immutable i_stakingToken;
    IERC20 public immutable i_rewardToken;

    /*//////////////////////////////////////////////////////////////
                                MAPPINGS
    //////////////////////////////////////////////////////////////*/

    mapping(address => uint256) private _balances; // user's stakingToken balance
    mapping(address => uint256) public userRewardPerTokenPaid; // Formüldeki P değeri
    mapping(address => uint256) public rewards; //

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    uint256 public s_rewardRate = 100; // saniyede kazılan ödül miktarı formüldeki R değeri
    uint256 public s_lastUpdateTime; // kontratın son çağrılma zamanı
    uint256 public s_rewardPerTokenStored; //  matematik formülündeki S değeri
    // Earned = s_rewardPerTokenStored - userRewardPerTokenPaid[user]
    uint256 private constant MULTIPLIER = 1e18; // precision için 18 basamak ekliyoruz
    uint256 private _totalSupply; // total number of token staked in this contract

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    // event staked(address indexed user, uint256 amountStaked);
    // event RewardAdded(uint256 rewardAmount);
    // event Withdrawed(address indexed user, uint256 amount);
    // event RewardPaid(address indexed user, uint256 reward);

    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

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

    function updateRewardRate(uint256 _rewardRate) public onlyOwner {
            require(_rewardRate > 0);
            s_rewardRate = _rewardRate;
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return 0;
        }

        return s_rewardPerTokenStored + (s_rewardRate * (block.timestamp - s_lastUpdateTime) * MULTIPLIER / _totalSupply);
    }

    function earned(address account) public view returns (uint256) {
        return ( _balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / MULTIPLIER) + rewards[account];


    } // tüm formül

    function stake(uint256 amount) external updateReward(msg.sender) {
        _totalSupply += amount;
        _balances[msg.sender] += amount;
        i_stakingToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function unstake(uint256 amount) external updateReward(msg.sender) {
        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        i_stakingToken.safeTransferFrom(address(this), msg.sender, amount);
    }

    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        i_rewardToken.safeTransferFrom(address(this), msg.sender, reward);
    }
}
