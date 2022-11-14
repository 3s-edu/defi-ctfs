// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AwardToken.sol";
import "../DefiCtfToken.sol";
import "./AccountingToken.sol";

contract TheAwarderPool {

    // Minimum duration of each round of awards in seconds
    uint256 private constant REWARDS_ROUND_MIN_DURATION = 5 days;

    uint256 public lastSnapshotIdForAwards;
    uint256 public lastRecordedSnapshotTimestamp;

    mapping(address => uint256) public lastAwardTimestamps;

    // Token deposited into the pool by users
    DefiCtfToken public immutable liquidityToken;

    // Token used for internal accounting and snapshots
    // Pegged 1:1 with the liquidity token
    AccountingToken public accToken;
    
    // Token in which awards are issued
    AwardToken public immutable awardToken;

    // Track number of rounds
    uint256 public roundNumber;

    constructor(address tokenAddress) {
        // Assuming all three tokens have 18 decimals
        liquidityToken = DefiCtfToken(tokenAddress);
        accToken = new AccountingToken();
        awardToken = new AwardToken();

        _recordSnapshot();
    }

    /**
     * @notice sender must have approved `amountToDeposit` liquidity tokens in advance
     */
    function deposit(uint256 amountToDeposit) external {
        require(amountToDeposit > 0, "Must deposit tokens");
        
        accToken.mint(msg.sender, amountToDeposit);
        distributeAwards();

        require(
            liquidityToken.transferFrom(msg.sender, address(this), amountToDeposit)
        );
    }

    function withdraw(uint256 amountToWithdraw) external {
        accToken.burn(msg.sender, amountToWithdraw);
        require(liquidityToken.transfer(msg.sender, amountToWithdraw));
    }

    function distributeAwards() public returns (uint256) {
        uint256 awards = 0;

        if(isNewAwardsRound()) {
            _recordSnapshot();
        }        
        
        uint256 totalDeposits = accToken.totalSupplyAt(lastSnapshotIdForAwards);
        uint256 amountDeposited = accToken.balanceOfAt(msg.sender, lastSnapshotIdForAwards);

        if (amountDeposited > 0 && totalDeposits > 0) {
            awards = (amountDeposited * 100 * 10 ** 18) / totalDeposits;

            if(awards > 0 && !_hasRetrievedAward(msg.sender)) {
                awardToken.mint(msg.sender, awards);
                lastAwardTimestamps[msg.sender] = block.timestamp;
            }
        }

        return awards;     
    }

    function _recordSnapshot() private {
        lastSnapshotIdForAwards = accToken.snapshot();
        lastRecordedSnapshotTimestamp = block.timestamp;
        roundNumber++;
    }

    function _hasRetrievedAward(address account) private view returns (bool) {
        return (
            lastAwardTimestamps[account] >= lastRecordedSnapshotTimestamp &&
            lastAwardTimestamps[account] <= lastRecordedSnapshotTimestamp + REWARDS_ROUND_MIN_DURATION
        );
    }

    function isNewAwardsRound() public view returns (bool) {
        return block.timestamp >= lastRecordedSnapshotTimestamp + REWARDS_ROUND_MIN_DURATION;
    }
}
