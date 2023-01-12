const { network, ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const rewardToken = await ethers.getContract("RewardToken");
  const stakingToken = await ethers.getContract("StakingToken");

  const stakingDevelopment = await deploy("Staking", {
    from: deployer,
    args: [rewardToken.address, stakingToken.address],
    log: true,
  });
};

module.exports.tags = ["all", "staking"];
