// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

interface IERC20 {}

contract AVSAggregator {
    /**
     * submits RewardsSubmissions to RewardsManager 
     * all eligibility checks (such as slashing checks etc) should happen here
     */
    function submitRewards() external {}

    /**
     * submits a Merkle root for submission to RewardsManager based on data from RewardsSubmissions
     */
    function submitRewardsRoot() external {}

    /**
     * function to check if an operator is slashed (if slashing affects claims)
     */
    function isSlashed(address) external returns (bool) {}

    // ... other AVS-related logic
}

interface IStrategy {
    // entrypoint for moving restaked assets in and out of the system
}

contract RewardsManager {

    /**
     * Structure for collecting rewards for Operators (and their Delegators) who have opted-in to active strategies in the given time period
     */
    struct RewardsSubmission {
        IStrategy[] strategies; // staked assets which generate rewards for Operators and Delegators
        IERC20 token;
        uint256 rewardAmount;
        // ...any necessary time variables 
    }

    /**
     * Merkle root against which rewards may be claimed by users
     */
    struct RewardsRoot {
        bytes32 merkleRoot; 
        uint32 rewardsEndTimestamp; // the point (seconds) until which rewards were calculated
        uint32 claimableTimestamp; // the point (seconds) when users may claim against root
        bool isDisabled; // a way to "disable" root to make it unclaimable in the event of an error when submitting rewards
        bytes32 rewardsSubmissionHash; // has of RewardsSubmission submitted with root 
        // ...any other data relevant to merkle tree
    }

    /**
     * Leaves in the RewardsRoot tree representing Operators & Delegators
     * Each leaf contains the root of a subtree for trackins ERC20 amounts earned
     */
    struct RewardsRecipientLeaf {
        address recipient; // the delegator, operator or provider
        bytes32 tokenRoot; // root of the TokenLeaf subtree (one for each token owed to user)
    }

    /**
     * Leaves in the tokenRoot subtree defined in each user's RewardsRecipientLeaf
     */
    struct TokenLeaf {
        IERC20 token;
        uint256 cumulativeAmount; // to be compared against cumulativeAmountClaimed when claiming rewards
    }

    /**
     * struct to provide proofs to claim rewards against Rewards Root
     */
    struct RewardsClaim {
        uint32 rewardsRootIndex; // index of root stored in `rewardsRoots`
        uint32 rewardsRecipientLeafIndex; // index of user's RewardsRecipientLeaf
        bytes recipientProof; // proof that recipient leaf exists within RewardsRoot
        RewardsRecipientLeaf recipientLeaf; // recipient's RewardsRecipientLeaf struct 
        uint32[] tokenLeafIndices; // claimable tokens within the recipient's tokenRoot subtree
        bytes32[] tokenLeavesProofs; // proofs agains tokenRoot
        TokenLeaf[] tokenLeaves; // TokenLeaf structs for each claimable token
    }

    /**
     * Mandatory time added to `claimableTimestamp` in submitted rewards root to create a delay period in which erroneous roots could be withdrawn
     */
    uint32 public constant CLAIM_DELAY = 1 days;

    /**
     * Merkle roots against which users may claim rewards
     */
    RewardsRoot[] private rewardsRoots;

    /**
     * AVS => RewardsSubmission hash => bool  
     */
    mapping(address => mapping(bytes32 => bool)) private rewardsSubmitted;

    /**
     * Record of the amount of ERC20 that has been claimed by users
     * to be compared against Rewards merkle tree
     */
    mapping(address user => mapping(IERC20 token => uint256 amount)) private cumulativeAmountClaimed;

    /**
     * @param submissions RewardsSubmission[] for a given AVS to be checked and hashed 
     * Should only be callable by AVSManager
     * Should collect all tokens outlined in IStrategy[] within each RewardsSubmission 
     */
    function createRewardsSubmission(RewardsSubmission[] calldata submissions) external {}

    /**
     * @param rewardsRoot the calculated merkle root for and timestamps
     * Should only be callable by AVSAggregator 
     */
    function createRewardsRoot(RewardsRoot calldata rewardsRoot) external {}

    /**
     * Disables a RewardsRoot in the event of an error
     * Should only be callable by AVSAggregator
     * @param rewardsRootIndex index in rewardsRoots[]
     */
    function disableRewardsRoot(uint256 rewardsRootIndex) external {}

    /**
     * Checks proofs against RewardsRoot specified in RewardsClaim
     * Should enforce claimableTimestamp in RewardsRoot + CLAIM_DELAY
     * Calculates amounts against cumulativeAmountClaimed and transfers to caller 
     * @param claim RewardsClaim with relevant Merkle proofs
     */
    function claimRewards(RewardsClaim calldata claim) external {}

}