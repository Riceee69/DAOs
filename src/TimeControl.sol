// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract TimeControl is TimelockController {
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors) TimelockController(minDelay, proposers, executors, msg.sender) {}
}