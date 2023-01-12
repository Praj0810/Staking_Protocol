//SPDX-License-Identifier: MIT

pragma solidity 0.8.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error StakingTransferFailed();

contract Staking {
    // staking token in IERC20
    IERC20 public stakingToken;
    //reward token in IERC20
    IERC20 public rewardToken;
    //owner of this contract
    address public owner;
    //duration in which stake token is locked
    uint256 public duration;
    //time at which the reward token expires
    uint256 public finishAt;
    //last time the reward token was updated;
    uint256 public updatedAt;
    //mapping to stored rewards earned by user
    mapping(address => uint256) public rewards;
    //Reward rate is calculated of futher calculation 
    uint256 public rewardRate;
    //totalSupply of the stakingtoken staked in pool
    uint256 public totalSupply;
    //reward per token stored in this variable
    uint256 public rewardPerTokenStored;
    //mapping of rewards already paid to the user is stored here
    mapping(address => uint256) public userRewardPerTokenPaid;
    //mapping to stored balance of user;
    mapping(address  => uint256) public balanceOf;

    modifier onlyOwner(){
        require(msg.sender == owner , "Not owner");
        _;
    }

    modifier updatedReward(address _account){
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();
        if(_account != address(0)){
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    constructor(address _stakingToken, address _rewardsToken){
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardsToken);
    }

    // duration of the Rewards is set by the owner of this contract and check of duration is over or not.
    function setRewardDuration(uint256 _duration) external onlyOwner {
        require(finishAt < block.timestamp, "Duration is not yet finish");
        duration = _duration; //1sec
    }
    //In this function the rewardRate is calculated based on time
    function notifyRewardsAmount(uint256 _amount) external onlyOwner{
        if(finishAt > block.timestamp){
            rewardRate = _amount/ duration;
        }else{
            uint256 remainingRewards = rewardRate * (finishAt - block.timestamp);
            rewardRate = remainingRewards + _amount/ duration;
        }
        require(rewardRate > 0, "reward rate = 0");
        require(rewardRate * duration <= rewardToken.balanceOf(address(this)), " RewardRate > balance of rewardsToken" );
        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;//
    }
   

    function stake(uint256 _amount)external updatedReward(msg.sender){
        require(_amount > 0 , "amount = 0");
        balanceOf[msg.sender]+= _amount;
        totalSupply += _amount;
        bool success = stakingToken.transferFrom(msg.sender,address(this), _amount);
        if(!success){
            revert StakingTransferFailed();
        }
    }

    function withdraw(uint256 _amount) external updatedReward(msg.sender){
        require(_amount > 0 , "amount = 0");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        bool success = stakingToken.transfer(msg.sender, _amount);
        if(!success){
            revert StakingTransferFailed();
        }
    }

    function lastTimeRewardApplicable() public view returns(uint){
        return min(block.timestamp, finishAt);
    }

    function rewardPerToken() public view returns(uint){
        if(totalSupply == 0){
            return rewardPerTokenStored;
        }else{
            return rewardPerTokenStored + (rewardRate *(lastTimeRewardApplicable() - updatedAt)*1e18)/ totalSupply; 
        }
    }

    function earned(address _account) public view returns(uint) {
        return (balanceOf[_account]* (rewardPerToken() - userRewardPerTokenPaid[_account]))/ 1e18 + rewards[_account]; 

    }

    function claimRewards()external updatedReward(msg.sender){
        uint256 reward = rewards[msg.sender];
        if(reward > 0){
            rewards[msg.sender] = 0;
            rewardToken.transfer(msg.sender, reward);
        } 
    }

    function min(uint x, uint y)public pure returns(uint){
        return x > y ? x:y;
    }
}



