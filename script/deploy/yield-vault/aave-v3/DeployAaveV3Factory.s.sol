// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { AaveV3Optimism } from "aave-address-book/AaveV3Optimism.sol";
import { AaveV3ERC4626Factory, IPool, IRewardsController } from "yield-daddy/aave-v3/AaveV3ERC4626Factory.sol";

import { ScriptHelpers } from "../../../helpers/ScriptHelpers.sol";

contract DeployAaveV3Factory is ScriptHelpers {
  function run() public {
    vm.startBroadcast();

    if (block.chainid == OPTIMISM_CHAIN_ID) {
      new AaveV3ERC4626Factory(
        IPool(address(AaveV3Optimism.POOL)),
        EXECUTIVE_TEAM_OPTIMISM_ADDRESS, // Reward recipient,
        IRewardsController(address(AaveV3Optimism.DEFAULT_INCENTIVES_CONTROLLER))
      );
    }

    vm.stopBroadcast();
  }
}
