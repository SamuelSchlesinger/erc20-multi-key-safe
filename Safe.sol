// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "IERC20.sol";
import "Withdrawal.sol";

// A safe operated by a number of private keys
contract Safe {
  // All of the operators
  address[] _operators;
  // The number of operators which must approve of the withdrawal
  uint _k;
  // The expiration interval for a withdrawal
  uint256 _expirationInterval;

  constructor(address[] memory operators_, uint k_, uint256 expirationInterval_) {
    _operators = operators_;
    _k = k_;
    _expirationInterval = expirationInterval_;
  }

  function initiateWithdrawal(address _token, address _to, uint256 _amount) external returns (address) {
    Withdrawal withdrawal = new Withdrawal(_operators, _k, _token, _to,  _amount, block.timestamp + _expirationInterval, address(this));
    assert(IERC20(_token).transfer(address(withdrawal), _amount));
    emit WithdrawalCreated(_token, _to, _amount, address(withdrawal));
    return address(withdrawal);
  }

  event WithdrawalCreated(address _token, address _to, uint256 _amount, address _withdrawal);
}
