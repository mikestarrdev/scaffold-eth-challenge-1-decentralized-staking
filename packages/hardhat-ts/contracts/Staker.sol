//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import 'hardhat/console.sol';
import './ExampleExternalContract.sol';

contract Staker {
  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint256) public balances;

  uint256 public constant threshold = 0.1 ether;
  uint256 public deadline;
  event Stake(address indexed sender, uint256 amount);

  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // TODO: Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake() external payable {
    require(address(msg.sender).balance >= threshold, "Balance too low!");
    uint256 amount = 0.5 ether;
    require(balances[msg.sender] == 0, "Already staked");
    balances[msg.sender] = amount;
    (bool success,) = msg.sender.call{value:amount}("");
    require(success, "Transfer failed");
    emit Stake(msg.sender, msg.value);
  }

  // TODO: After some `deadline` allow anyone to call an `execute()` function
  //  It should call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() external {
    require(block.timestamp >= deadline, "Deadline not yet passed!");
    exampleExternalContract.complete{value: address(this).balance}();
  }

  /**
   * @dev _time is in seconds
   */
  function setDeadline(uint256 _time) private {
      deadline = _time;
    // 1. get deadline
    // 2. if block.timestamp > deadline, send funds to exampleExternalContract
  }

  // TODO: if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() public {
    require(block.timestamp > deadline, "Deadline has not yet passed");
    uint256 balance = balances[msg.sender];
    require(balance > 0, "Balance is 0");
    balances[msg.sender] = 0;
    address payable to = payable(msg.sender);
    to.transfer(balance);
  }

  // TODO: Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() view public returns (uint256) {
    require(block.timestamp < deadline, "Deadline has passed");
    uint256 time = block.timestamp - deadline;
    return time;
  }

  // TODO: Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    // stake();
  }
}
