//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {DAO} from "../src/DAO.sol";
import {TimeControl} from "../src/TimeControl.sol";
import {Governance} from "../src/Governance.sol";
import {GovernanceToken} from "../src/GovernanceToken.sol";

contract DeployDAO is Script {
    function run() public returns (Governance, DAO, GovernanceToken) {
        address[] memory proposers;
        address[] memory executors;
        uint256 MIN_DELAY = 1 hours;//delay between passing and execution of proposal

        vm.startBroadcast();
        GovernanceToken token = new GovernanceToken();
        TimeControl timelock = new TimeControl(MIN_DELAY, proposers, executors);
        Governance governance = new Governance(token, timelock);
        
        //edit the timecontrol roles///////////////////////////
        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();
        timelock.grantRole(proposerRole, address(governance));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, msg.sender);
        ///////////////////////////////////////////////////////

        DAO dao = new DAO();
        dao.transferOwnership(address(timelock));

        vm.stopBroadcast();

        return (governance, dao, token);
    }
}