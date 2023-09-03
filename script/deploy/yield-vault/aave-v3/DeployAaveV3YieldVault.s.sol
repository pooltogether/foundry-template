// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { AaveV3ERC4626Factory, ERC20 } from "yield-daddy/aave-v3/AaveV3ERC4626Factory.sol";

import { ScriptHelpers } from "../../../helpers/ScriptHelpers.sol";

contract DeployAaveV3YieldVault is ScriptHelpers {
  function run() public {
    vm.startBroadcast();

    AaveV3ERC4626Factory _aaveV3Factory = _getAaveV3Factory();

    /* USDC */
    _aaveV3Factory.createERC4626(ERC20(_getToken("USDC")));

    /* wETH */
    _aaveV3Factory.createERC4626(ERC20(_getToken("WETH")));

    /* LUSD */
    // _aaveV3Factory.createERC4626(ERC20(_getToken("LUSD")));

    vm.stopBroadcast();
  }
}
