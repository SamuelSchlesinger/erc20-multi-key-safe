// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "IERC20.sol";

contract Withdrawal {
  // The address to whom the withdrawal is going to
  address _to;
  // All of the operators
  address[] _operators;
  // The number of operators which must approve of the withdrawal
  uint _k;
  // The token being transferred
  address _token;
  // The quantity of the token being transferred
  uint256 _amount;
  // Whether or not an operator has assented
  mapping(address => bool) _votes;
  // Whether or not an operator is one of the _operators
  mapping(address => bool) _isOperator;
  // Expiration date
  uint256 _expiration;
  // Parent Safe contract
  address _parent;

  constructor(address[] memory operators_, uint k_, address token_, address to_, uint256 amount_, uint256 expiration_, address parent_) {
    _to = to_;
    _operators = operators_;
    _k = k_;
    _token = token_;
    _amount = amount_;
    _expiration = expiration_;
    _parent = parent_;
    for (uint i = 0; i < _operators.length; i++) {
      _isOperator[_operators[i]] = true;
    }
  }

  modifier notExpired() {
    assert(block.timestamp < _expiration);
    _;
  }

  modifier expired() {
    assert(block.timestamp >= _expiration);
    _;
  }

  modifier isOperator() {
    assert(_isOperator[msg.sender]);
    _;
  }

  modifier isApproved() {
    uint approvals = 0;
    for (uint i = 0; i < _operators.length; i++) {
      approvals = approvals + (_votes[_operators[i]] ? 1 : 0);
    }
    assert(approvals >= _k);
    _;
  }

  function approve() external notExpired isOperator {
    _votes[msg.sender] = true;
  }

  function disapprove() external notExpired isOperator {
    _votes[msg.sender] = false;
  }

  function dissolve() external expired isOperator {
    assert(IERC20(_token).transfer(_parent, _amount));
  }

  function activate() external notExpired isApproved isOperator {
    assert(IERC20(_token).transfer(_to, _amount));
  }
}
