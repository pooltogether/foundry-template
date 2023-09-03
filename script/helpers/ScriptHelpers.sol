// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/StdJson.sol";

import { LinkTokenInterface } from "chainlink/interfaces/LinkTokenInterface.sol";
import { VRFV2Wrapper } from "chainlink/vrf/VRFV2Wrapper.sol";
import { ERC4626 } from "openzeppelin/token/ERC20/extensions/ERC4626.sol";
import { Strings } from "openzeppelin/utils/Strings.sol";
import { UD2x18, ud2x18 } from "prb-math/UD2x18.sol";
import { SD1x18, sd1x18 } from "prb-math/SD1x18.sol";
import { strings } from "solidity-stringutils/strings.sol";
import { AaveV3ERC4626Factory } from "yield-daddy/aave-v3/AaveV3ERC4626Factory.sol";

import { Constants } from "../../src/Constants.sol";

abstract contract ScriptHelpers is Constants, Script {
  using strings for *;
  using stdJson for string;

  /* ============ Constants ============ */

  // Deployment paths
  string internal constant ETHEREUM_PATH = "broadcast/Deploy.s.sol/1/";
  string internal constant OPTIMISM_PATH = "broadcast/Deploy.s.sol/10/";
  string internal constant LOCAL_PATH = "/broadcast/Deploy.s.sol/31337";

  string internal DEPLOY_POOL_SCRIPT;

  /* ============ Helpers ============ */

  function _toDecimals(uint256 _amount, uint8 _decimals) internal pure returns (uint256) {
    return _amount * (10 ** _decimals);
  }

  function _getDeploymentArtifacts(
    string memory _deploymentArtifactsPath
  ) internal returns (string[] memory) {
    string[] memory inputs = new string[](4);
    inputs[0] = "ls";
    inputs[1] = "-m";
    inputs[2] = "-r";
    inputs[3] = string.concat(vm.projectRoot(), _deploymentArtifactsPath);
    bytes memory res = vm.ffi(inputs);

    // Slice ls result
    strings.slice memory s = string(res).toSlice();

    // Remove directory jargon at the beginning of the slice (Fix for Windows Git Bash)
    strings.slice memory dirEnd = "/:".toSlice();
    strings.slice memory sWithoutDirPrefix = s.copy().find(dirEnd).beyond(dirEnd);
    if (!sWithoutDirPrefix.empty()) s = sWithoutDirPrefix;

    // Remove newline and push into array
    strings.slice memory delim = ", ".toSlice();
    strings.slice memory sliceNewline = "\n".toSlice();
    string[] memory filesName = new string[](s.count(delim) + 1);

    for (uint256 i = 0; i < filesName.length; i++) {
      filesName[i] = s.split(delim).beyond(sliceNewline).toString();
    }

    return filesName;
  }

  function _getContractAddress(
    string memory _contractName,
    string memory _artifactsPath,
    string memory _errorMsg
  ) internal returns (address) {
    string[] memory filesName = _getDeploymentArtifacts(_artifactsPath);
    uint256 filesNameLength = filesName.length;

    // Loop through deployment artifacts and find latest deployed `_contractName` address
    for (uint256 i; i < filesNameLength; i++) {
      string memory filePath = string.concat(vm.projectRoot(), _artifactsPath, filesName[i]);
      string memory jsonFile = vm.readFile(filePath);
      bytes[] memory rawTxs = abi.decode(vm.parseJson(jsonFile, ".transactions"), (bytes[]));

      uint256 transactionsLength = rawTxs.length;

      for (uint256 j; j < transactionsLength; j++) {
        string memory contractName = abi.decode(
          stdJson.parseRaw(
            jsonFile,
            string.concat(".transactions[", vm.toString(j), "].contractName")
          ),
          (string)
        );

        if (
          keccak256(abi.encodePacked((contractName))) ==
          keccak256(abi.encodePacked((_contractName)))
        ) {
          address contractAddress = abi.decode(
            stdJson.parseRaw(
              jsonFile,
              string.concat(".transactions[", vm.toString(j), "].contractAddress")
            ),
            (address)
          );

          return contractAddress;
        }
      }
    }

    revert(_errorMsg);
  }

  function _getTokenAddress(
    string memory _contractName,
    string memory _tokenSymbol,
    uint256 _argumentPosition,
    string memory _artifactsPath,
    string memory _errorMsg
  ) internal returns (address) {
    string[] memory filesName = _getDeploymentArtifacts(_artifactsPath);

    // Loop through deployment artifacts and find latest deployed `_contractName` address
    for (uint256 i; i < filesName.length; i++) {
      string memory jsonFile = vm.readFile(
        string.concat(vm.projectRoot(), _artifactsPath, filesName[i])
      );

      bytes[] memory rawTxs = abi.decode(vm.parseJson(jsonFile, ".transactions"), (bytes[]));

      for (uint256 j; j < rawTxs.length; j++) {
        string memory index = vm.toString(j);

        string memory _argumentPositionString = vm.toString(_argumentPosition);

        if (
          _matches(
            abi.decode(
              stdJson.parseRaw(
                jsonFile,
                string.concat(".transactions[", index, "].transactionType")
              ),
              (string)
            ),
            "CREATE"
          ) &&
          _matches(
            abi.decode(
              stdJson.parseRaw(jsonFile, string.concat(".transactions[", index, "].contractName")),
              (string)
            ),
            _contractName
          ) &&
          _matches(
            abi.decode(
              stdJson.parseRaw(
                jsonFile,
                string.concat(".transactions[", index, "].arguments[", _argumentPositionString, "]")
              ),
              (string)
            ),
            _tokenSymbol
          )
        ) {
          return
            abi.decode(
              stdJson.parseRaw(
                jsonFile,
                string.concat(".transactions[", index, "].contractAddress")
              ),
              (address)
            );
        }
      }
    }

    revert(_errorMsg);
  }

  function _getDeployPath(string memory _deployPath) internal view returns (string memory) {
    return _getDeployPathWithChainId(_deployPath, block.chainid);
  }

  function _getDeployPathWithChainId(
    string memory _deployPath,
    uint256 chainId
  ) internal pure returns (string memory) {
    return string.concat("/broadcast/", _deployPath, "/", Strings.toString(chainId), "/");
  }

  /* ============ Getters ============ */

  // Yield Vaults
  // Aave V3
  function _getAaveV3Factory() internal returns (AaveV3ERC4626Factory) {
    return
      AaveV3ERC4626Factory(
        _getContractAddress(
          "AaveV3ERC4626Factory",
          _getDeployPath("DeployAaveV3Factory.s.sol"),
          "aave-3-factory-not-found"
        )
      );
  }

  function _getAaveV3YieldVault(address _underlyingAsset) internal returns (ERC4626) {
    string memory _artifactsPath = _getDeployPath("DeployAaveV3YieldVault.s.sol");
    string[] memory filesName = _getDeploymentArtifacts(_artifactsPath);
    uint256 filesNameLength = filesName.length;

    // Loop through deployment artifacts and use function signature to find Aave V3 Yield Vault
    for (uint256 i; i < filesNameLength; i++) {
      string memory jsonFile = vm.readFile(
        string.concat(vm.projectRoot(), _artifactsPath, filesName[i])
      );

      bytes[] memory rawTxs = abi.decode(vm.parseJson(jsonFile, ".transactions"), (bytes[]));
      uint256 transactionsLength = rawTxs.length;

      for (uint256 j; j < transactionsLength; j++) {
        if (
          keccak256(
            abi.encodePacked(
              abi.encodeWithSelector(bytes4(keccak256("createERC4626(address)")), _underlyingAsset)
            )
          ) ==
          keccak256(
            abi.encodePacked(
              abi.decode(
                stdJson.parseRaw(
                  jsonFile,
                  string.concat(".transactions[", vm.toString(j), "].transaction.data")
                ),
                (string)
              )
            )
          )
        ) {
          return
            ERC4626(
              abi.decode(
                stdJson.parseRaw(
                  jsonFile,
                  string.concat(
                    ".transactions[",
                    vm.toString(j),
                    "].additionalContracts[0].address"
                  )
                ),
                (address)
              )
            );
        }
      }
    }

    revert("aave-v3-yield-vault-not-found");
  }

  function _getLinkToken() internal view returns (LinkTokenInterface) {
    if (block.chainid == ETHEREUM_CHAIN_ID) {
      return LinkTokenInterface(address(0x514910771AF9Ca656af840dff83E8264EcF986CA));
    } else {
      revert("Link token address not set in `_getLinkToken` for this chain.");
    }
  }

  function _getVrfV2Wrapper() internal view returns (VRFV2Wrapper) {
    if (block.chainid == ETHEREUM_CHAIN_ID) {
      return VRFV2Wrapper(address(0x5A861794B927983406fCE1D062e00b9368d97Df6));
    } else {
      revert("VRF V2 Wrapper address not set in `_getVrfV2Wrapper` for this chain.");
    }
  }
}
