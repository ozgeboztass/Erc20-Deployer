// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";

contract GovernorContract is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction {
    constructor(IVotes _token)
        Governor("GovernorContract")
        GovernorSettings(1 /* 1 block */, 45818 /* 1 week */, 0)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
    {}

    // Aşağıdaki işlevler çeşitli ebeveynlerden gelen işlevleri geçersiz kılmalıdır
    function votingDelay() public view override(IGovernor, GovernorSettings) returns (uint256) {
        return super.votingDelay();
    }

    function votingPeriod() public view override(IGovernor, GovernorSettings) returns (uint256) {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber) public view override(IGovernor, GovernorVotesQuorumFraction) returns (uint256) {
        return super.quorum(blockNumber);
    }

    function state(uint256 proposalId) public view override(Governor, IGovernor) returns (ProposalState) {
        return super.state(proposalId);
    }

    function propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description)
        public
        override(Governor, IGovernor)
        returns (uint256)
    {
        return super.propose(targets, values, calldatas, description);
    }

    function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(Governor) returns (address) {
        return super._executor();
    }

    function _getVotes(address account, uint256 blockNumber, bytes memory params)
        internal
        view
        override(Governor, GovernorVotes)
        returns (uint256)
    {
        return super._getVotes(account, blockNumber, params);
    }
}const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying GovernanceToken...");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const GovernanceToken = await ethers.getContractFactory("GovernanceToken");
  const governanceToken = await GovernanceToken.deploy("GovernanceToken", "GT");
  await governanceToken.deployed();
  console.log("GovernanceToken deployed to:", governanceToken.address);

  console.log("Deploying GovernorContract...");

  const GovernorContract = await ethers.getContractFactory("GovernorContract");
  const governorContract = await GovernorContract.deploy(governanceToken.address);
  await governorContract.deployed();
  console.log("GovernorContract deployed to:", governorContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying GovernanceToken...");

  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const GovernanceToken = await ethers.getContractFactory("GovernanceToken");
  const governanceToken = await GovernanceToken.deploy("GovernanceToken", "GT");
  await governanceToken.deployed();
  console.log("GovernanceToken deployed to:", governanceToken.address);

  console.log("Deploying GovernorContract...");

  const GovernorContract = await ethers.getContractFactory("GovernorContract");
  const governorContract = await GovernorContract.deploy(governanceToken.address);
  await governorContract.deployed();
  console.log("GovernorContract deployed to:", governorContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });