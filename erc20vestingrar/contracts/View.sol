// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./TimeLockPool.sol";


/// @dev reader contract to easily fetch all relevant info for an account
contract View {

    struct Data {
        Pool[] pools;
        Pool escrowPool;
    }

    struct Deposit {
        uint256 amount;
        uint64 start;
        uint64 end;
        uint256 multiplier;
    }

    struct Pool {
        address poolAddress;
        uint256 totalPoolShares;
        address depositToken;
        uint256 accountPendingRewards;
        uint256 accountClaimedRewards;
        uint256 accountTotalDeposit;
        uint256 accountPoolShares;
        Deposit[] deposits;
    }

    address[] stakingPool = [0x0571C76d66023f0A8aF3580E33877a8C4EEbAa76, 0x36eBCEaf824b21fA86A88BA30FE267F5aaFcDE8C];
    TimeLockPool public immutable escrowPool;

    constructor(address[] memory _pools, address _escrowPool) {
        escrowPool = TimeLockPool(_escrowPool);
        for(uint8 i = 0; i <stakingPool.length; i++) {
            stakingPool[i] = _pools[i];
        }
    }

    function fetchData(address _account) external view returns (Data memory result) {

        result.pools = new Pool[](stakingPool.length);

        for(uint256 i = 0; i < stakingPool.length; i ++) { 

            TimeLockPool poolContract = TimeLockPool(stakingPool[i]);

            result.pools[i] = Pool({
                poolAddress: address(stakingPool[i]),
                totalPoolShares: poolContract.totalSupply(),
                depositToken: address(poolContract.depositToken()),
                accountPendingRewards: poolContract.withdrawableRewardsOf(_account),
                accountClaimedRewards: poolContract.withdrawnRewardsOf(_account),
                accountTotalDeposit: poolContract.getTotalDeposit(_account),
                accountPoolShares: poolContract.balanceOf(_account),
                deposits: new Deposit[](poolContract.getDepositsOfLength(_account))
            });

            TimeLockPool.Deposit[] memory deposits = poolContract.getDepositsOf(_account);

            for(uint256 j = 0; j < result.pools[i].deposits.length; j ++) {
                TimeLockPool.Deposit memory deposit = deposits[j];
                result.pools[i].deposits[j] = Deposit({
                    amount: deposit.amount,
                    start: deposit.start,
                    end: deposit.end,
                    multiplier: poolContract.getMultiplier(deposit.end - deposit.start)
                });
            }

            
        }

        result.escrowPool = Pool({
            poolAddress: address(escrowPool),
            totalPoolShares: escrowPool.totalSupply(),
            depositToken: address(escrowPool.depositToken()),
            accountPendingRewards: escrowPool.withdrawableRewardsOf(_account),
            accountClaimedRewards: escrowPool.withdrawnRewardsOf(_account),
            accountTotalDeposit: escrowPool.getTotalDeposit(_account),
            accountPoolShares: escrowPool.balanceOf(_account),
            deposits: new Deposit[](escrowPool.getDepositsOfLength(_account))
        });

        TimeLockPool.Deposit[] memory deposits = escrowPool.getDepositsOf(_account);

        for(uint256 j = 0; j < result.escrowPool.deposits.length; j ++) {
            TimeLockPool.Deposit memory deposit = deposits[j];
            result.escrowPool.deposits[j] = Deposit({
                amount: deposit.amount,
                start: deposit.start,
                end: deposit.end,
                multiplier: escrowPool.getMultiplier(deposit.end - deposit.start)
            });
        } 

    }

}