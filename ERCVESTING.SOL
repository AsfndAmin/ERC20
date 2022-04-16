// SPDX-License-Identifier: un-license
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vesting is Ownable {
    uint256 public _vestingPeriod;
    uint256 public _startTime;
    IERC20 private _token;

    mapping(address => VestingInfo) internal _beneficiaryInfo;

    event Claimed(address account, uint256 amount);
    struct VestingInfo {
        uint256 amount;
        uint256 vestingPeriod;
    }

    constructor(
        address token_,
        address[] memory beneficiary_,
        uint256[] memory amount_,
        uint256 vestingPeriod_
    ) {
        _token = IERC20(token_);
        _startTime = block.timestamp;
        require(
            beneficiary_.length == amount_.length,
            "beneficiary and amount quantity not equal"
        );
        for (uint256 vestIndex = 0; vestIndex < amount_.length; vestIndex++) { 
            _beneficiaryInfo[beneficiary_[vestIndex]] = VestingInfo({
                amount: amount_[vestIndex] * 10 ** decimals(),
                vestingPeriod: block.timestamp + vestingPeriod_
            });
        }
    }
    
    function setVest(address[] memory beneficiary, uint256[] memory amount, uint256 vestTime) external {
        require(beneficiary.length == amount.length,
            "beneficiary and amount quantity not equal"
        );
        for (uint256 vestIndex = 0; vestIndex < amount.length; vestIndex++) {
            _beneficiaryInfo[beneficiary[vestIndex]] = VestingInfo({
                amount: amount[vestIndex] * 10 ** decimals(),
                vestingPeriod: block.timestamp + vestTime
            });
        }
    }

    function claim() external {
        require(
            msg.sender != address(0),
            "msg.sender can not be a zero address"
        );
        VestingInfo storage info = _beneficiaryInfo[msg.sender];
        
        require(block.timestamp >= info.vestingPeriod, "Unlocked period not arrived");
        require(info.amount > 0, "No tokens for claim");
        
        _token.transfer(msg.sender, info.amount);
        emit Claimed(msg.sender, info.amount);
    }
    
    function getVestingInfo(address user) external view returns(VestingInfo memory) {
        return _beneficiaryInfo[user];
    }
    
    function decimals() public pure returns (uint8) {
        return 18;
    }
}
