pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenVesting is Ownable {
   
    event EtherReleased(uint256 amount);
    event ERC20Released(address indexed token, uint256 amount);
    event Revoked();
    
    
    using SafeERC20 for IERC20;
    uint256 private _released;
    bool public revoked;
    address private _beneficiary;
    uint64 private immutable _start;
    uint64 private immutable _duration;
    bool public revocable;
    uint256 public _cliff;
    mapping(address => uint256) private _erc20Released;
    mapping (address => bool) public _erc20Revoked;

    /**
     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.
     */
    constructor(
        address beneficiaryAddress,
        uint64 startTimestamp,
        uint64 durationSeconds,
        uint64 cliffTimestamp
    ) {
        require(beneficiaryAddress != address(0), "VestingWallet: beneficiary is zero address");
        _beneficiary = beneficiaryAddress;
        _start = startTimestamp;
        _duration = durationSeconds;
        _cliff = _start+cliffTimestamp;
      
    }

    /**
     * @dev The contract should be able to receive Eth.
     */
    receive() external payable virtual {}

    /**
     * @dev Getter for the beneficiary address.
     */
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }

    /**
    * @dev Setter for updating beneficiary address
     */
    function updateBenificary(address update_beneficiary) private {
        _beneficiary = update_beneficiary;
    }

    /**
     * @dev Getter for the start timestamp.
     */
    function start() public view virtual returns (uint256) {
        return _start;
    }

    /**
     * @dev Getter for the vesting duration.
     */
    function duration() public view virtual returns (uint256) {
        return _duration;
    }

    /**
     * @dev Amount of eth already released
     */
    function released() public view virtual returns (uint256) {
        return _released;
    }

    /**
     * @dev Amount of token already released
     */
    function released(address token) public view virtual returns (uint256) {
        return _erc20Released[token];
    }

    /**
    
     */

  function revoke(address token) public onlyOwner {
    require(revocable);
    require(!_erc20Revoked[token]);

    uint256 balance = IERC20(token).balanceOf(address(this));

    uint256 unreleased = vestedAmount(token, uint64(block.timestamp)) - released(token);
    uint256 refund = balance - unreleased;

    _erc20Revoked[token] = true;

    IERC20(token).safeTransfer(Ownable.owner(), refund);

    emit Revoked();
  }
    function revoke() public onlyOwner {
        require(revocable);
        require(!revoked);
        uint256 unreleased = vestedAmount(uint64(block.timestamp)) - released();
        uint256 refund = address(this).balance - unreleased;
        revoked = true;
        Address.sendValue(payable(beneficiary()), refund);
        emit Revoked();
  }
    /**
     * @dev Release the native token (ether) that have already vested.
     *
     * Emits a {TokensReleased} event.
     */
    function release() public virtual {
        require(uint64(block.timestamp) > _cliff,"Cannot claim before cliff period");
        uint256 releasable = vestedAmount(uint64(block.timestamp)) - released();
        require(releasable >0,"Not enough balance to release");
        _released += releasable;
        emit EtherReleased(releasable);
        Address.sendValue(payable(beneficiary()), releasable);
    }

    /**
     * @dev Release the tokens that have already vested.
     *
     * Emits a {TokensReleased} event.
     */
    function release(address token) public virtual {
        require(uint64(block.timestamp) > _cliff,"Cannot claim before cliff period");
        uint256 releasable = vestedAmount(token, uint64(block.timestamp)) - released(token);
        require(releasable >0,"Not enough balance to release");
        _erc20Released[token] += releasable;
        emit ERC20Released(token, releasable);
        SafeERC20.safeTransfer(IERC20(token), beneficiary(), releasable);
    }

    /**
     * @dev Calculates the amount of ether that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(uint64 timestamp) public view virtual returns (uint256) {
         if(revoked){
             return address(this).balance + released();
         }else{
             return _vestingSchedule(address(this).balance + released(), timestamp);
         }
      
    }

    /**
     * @dev Calculates the amount of tokens that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(address token, uint64 timestamp) public view virtual returns (uint256) {
          if(revoked){
              return IERC20(token).balanceOf(address(this)) + released(token);
          }else{
              return _vestingSchedule(IERC20(token).balanceOf(address(this)) + released(token), timestamp);
          }
        
    }

    /**
     * @dev Virtual implementation of the vesting formula. This returns the amount vested, as a function of time, for
     * an asset given its total historical allocation.
     */
    function _vestingSchedule(uint256 totalAllocation, uint64 timestamp) internal view virtual returns (uint256) {
        if (timestamp < _cliff) {
            return 0;
        } else if (timestamp > start() + duration()) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start())) / duration();
        }
    }
}