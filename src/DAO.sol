//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DAO is Ownable {
    //Minimalistic DAO
    uint256 public participantLimit = 10;

    event UpdateParticipantLimit(uint256 participantLimit);

    constructor() Ownable(msg.sender) {}

    function updateParticipantLimit(uint256 _participantLimit) public onlyOwner {
        participantLimit = _participantLimit;
        emit UpdateParticipantLimit(_participantLimit);
    }
}