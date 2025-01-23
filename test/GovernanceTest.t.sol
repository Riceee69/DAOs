//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Governance} from "../src/Governance.sol";
import {TimeControl} from "../src/TimeControl.sol";
import {DAO} from "../src/DAO.sol";
import {GovernanceToken} from "../src/GovernanceToken.sol";
import {DeployDAO} from "../script/DeployDAO.s.sol";

contract GovernanceTest is Test {
    Governance governance;
    DAO dao;
    GovernanceToken token;

    address VOTER = makeAddr("voterCumOwner");

    //timelock requirements
    uint256 MIN_DELAY = 1 hours;//delay to execute after passing of proposal

    //propsal requirements
    uint48 constant VOTING_DELAY = 7200;
    uint32 constant VOTING_PERIOD = 50400;
    address[] targets;
    uint256[] values;
    bytes[] calldatas;
    string description;

    function setUp() public {
        //token = new GovernanceToken();
        DeployDAO deploy = new DeployDAO();
        (governance, dao, token) = deploy.run();

        token.mint(VOTER, 1e18);
        vm.prank(VOTER);
        token.delegate(VOTER);//delegate to self
    }

    function testGovernanceUpdatesParticipantLimit() public {
        uint256 newParticipantLimit = 777;
        description = "Update participant limit to 777 in DAO";
        targets.push(address(dao));
        values.push(0);
        bytes memory encodedFunctionCall = abi.encodeWithSelector(DAO.updateParticipantLimit.selector, newParticipantLimit);
        calldatas.push(encodedFunctionCall);
        // 1. Propose to the DAO
        uint256 proposalId = governance.propose(targets, values, calldatas, description);

        console.log("Proposal State:", uint256(governance.state(proposalId)));
        console.log("Proposal Snapshot:", governance.proposalSnapshot(proposalId));
        console.log("Proposal Deadline:", governance.proposalDeadline(proposalId));

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console.log("Proposal State After Voting Delay:", uint256(governance.state(proposalId)));

        // 2. Vote
        // 0 = Against, 1 = For, 2 = Abstain for this example
        uint8 voteWay = 1;
        vm.prank(VOTER);
        governance.castVote(proposalId, voteWay);

        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        console.log("Proposal State After Voting Period:", uint256(governance.state(proposalId)));

        // 3. Queue
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governance.queue(targets, values, calldatas, descriptionHash);
        vm.roll(block.number + MIN_DELAY + 1);
        vm.warp(block.timestamp + MIN_DELAY + 1);

        // 4. Execute
        governance.execute(targets, values, calldatas, descriptionHash);

        assert(dao.participantLimit() == newParticipantLimit);
    }
}