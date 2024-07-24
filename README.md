# Abstract
Create a reward management system for an AVS which has 3 classes of actors: Delegators, Operators, and Providers.
- Delegators: stake value with Operators
- Operators: opt into AVSs and run additional node software (if they are performing their own computation, they can be considered Providers, if not we can assume they are operating NodeOps nodes)
- Providers: operators who are running their own computation outside of NodeOps

# Scope
I have presented a minimal interface with comments, plus notes on design thinking in this document. 

The contract is agnostic about different incentives for Providers running their own compute vs Operators running NodeOps nodes. 


## Contracts
- AVSAggregator - singleton NodeOps contract for managing active AVSs and submitting rewards to RewardsManager
- Strategy - restaked asset contracts which define rewards split conditions between Operators and Delegators
- RewardsManager - contract for distributing rewards earned from participation in AVSs within the NodeOps system 

## Access control
AVSAggregator should be the only address which can create Rewards Submissions. The interface is agnostic as to how the AVSAggregator implements access control.

## Rewards calculations
It is assumed that the rewards will be calculated off-chain at regular intervals (for example every 24-hours) and relayed to the RewardsManager smart contract by AVSAggregator. The specific strategies for incentivizing participation as well as the methods for verifying participation in a given AVS are considered outside the scope of this exercise. 

## Rewards distribution
Calculated rewards are submitted to the RewardsManager, first as a RewardsSubmission (which hashes the data and transfers tokens to the RewardManager), then as a RewardsRoot which may be claimed against by Operators and Delegators.

## Time delays for claims
A mandatory time delay is set on claims to give AVSAggregator an opportunity to withdraw erroneous Merkle root calculations

## Claimable window
Users may claim against any valid RewardsRoot, as balance is tracked by `cumulativeAmountClaimed` mapping.
