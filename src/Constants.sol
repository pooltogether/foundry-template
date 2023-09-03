// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { SD1x18, sd1x18 } from "prb-math/SD1x18.sol";
import { wrap, SD59x18 } from "prb-math/SD59x18.sol";
import { UD2x18, ud2x18 } from "prb-math/UD2x18.sol";

abstract contract Constants {
  // Addresses
  // Defender
  address internal constant ETHEREUM_DEFENDER_ADDRESS = 0xA2A8BccD38138f1169ADdb0f3df9236a3CCCd753;
  address internal constant OPTIMISM_DEFENDER_ADDRESS = 0xCeA11E14067697C085e1142afd2540b23f18304D;

  // MessageExecutor
  address internal constant ERC5164_EXECUTOR_OPTIMISM = 0x890a87E71E731342a6d10e7628bd1F0733ce3296;

  // Multisigs
  address internal constant EXECUTIVE_TEAM_ETHEREUM_ADDRESS =
    0xDa63D70332139E6A8eCA7513f4b6E2E0Dc93b693;

  address internal constant EXECUTIVE_TEAM_OPTIMISM_ADDRESS =
    0x8d352083F7094dc51Cd7dA8c5C0985AD6e149629;

  // Chain IDs
  uint256 internal constant ETHEREUM_CHAIN_ID = 1;
  uint256 internal constant OPTIMISM_CHAIN_ID = 10;

  // Deploy parameters
  // Chainlink VRF
  uint32 internal constant CHAINLINK_CALLBACK_GAS_LIMIT = 200_000;
  uint16 internal constant CHAINLINK_REQUEST_CONFIRMATIONS = 3;

  // Claimer
  uint256 internal constant CLAIMER_MIN_FEE = 0.0001e18;
  uint256 internal constant CLAIMER_MAX_FEE = 10000e18;

  function _getClaimerTimeToReachMaxFee() internal pure returns (uint256) {
    return (DRAW_PERIOD_SECONDS - (2 * AUCTION_DURATION)) / 2;
  }

  function _getClaimerMaxFeePortionOfPrize() internal pure returns (UD2x18) {
    return ud2x18(0.5e18);
  }

  // Liquidation Pair
  uint104 internal constant ONE_POOL = 1e18;

  /**
   * @notice Get exchange rate for liquidation pair `virtualReserveOut`.
   * @param _tokenPrice Price of the token represented in 8 decimals
   * @param _decimalOffset Offset between the prize token decimals and the token decimals
   */
  function _getExchangeRate(
    uint256 _tokenPrice,
    uint8 _decimalOffset
  ) internal pure returns (uint104) {
    return uint104((PRIZE_TOKEN_PRICE * 1e8) / (_tokenPrice * (10 ** _decimalOffset)));
  }

  function _getTargetFirstSaleTime(uint32 _drawPeriodSeconds) internal pure returns (uint32) {
    return _drawPeriodSeconds / 2;
  }

  /**
   * @notice Get Liquidation Pair decay constant.
   * @dev This is approximately the maximum decay constant, as the CGDA formula requires computing e^(decayConstant * time).
   *      Since the data type is SD59x18 and e^134 ~= 1e58, we can divide 134 by the draw period to get the max decay constant.
   */
  function _getDecayConstant() internal pure returns (SD59x18) {
    return SD59x18.wrap(0.000030092592592592e18);
  }

  // Prize Pool
  uint32 internal constant DRAW_PERIOD_SECONDS = 1 days;
  uint24 internal constant GRAND_PRIZE_PERIOD_DRAWS = 365; // Once a year for daily draws
  uint8 internal constant MIN_NUMBER_OF_TIERS = 3;
  uint256 internal constant MIN_TIME_AHEAD = DRAW_PERIOD_SECONDS;
  uint8 internal constant RESERVE_SHARES = 100;
  uint8 internal constant TIER_SHARES = 100;

  function _getContributionsSmoothing() internal pure returns (SD1x18) {
    return sd1x18(0.3e18);
  }

  /// @notice Returns the start timestamp of the first draw.
  function _getFirstDrawStartsAt() internal pure returns (uint64) {
    return uint64(1693594800); // Sep 1, 2023, 7:00:00 PM UTC
  }

  // RngAuctions
  uint64 internal constant AUCTION_DURATION = 6 hours;
  uint64 internal constant AUCTION_TARGET_SALE_TIME = 1 hours;
  uint256 internal constant AUCTION_MAX_REWARD = 10000e18;

  /// @notice Returns the timestamp of the auction offset, aligned to the draw offset.
  function _getAuctionOffset() internal pure returns (uint32) {
    return uint32(_getFirstDrawStartsAt() - 3 days);
  }

  // Twab
  // nice round fraction of the draw period
  uint32 internal constant TWAB_PERIOD_LENGTH = 1 hours;

  // Timestamps
  uint256 internal constant ONE_YEAR_IN_SECONDS = 31557600;

  // Token addresses
  address internal constant ETHEREUM_POOL_ADDRESS = 0x0cEC1A9154Ff802e7934Fc916Ed7Ca50bDE6844e;
  address internal constant ETHEREUM_USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address internal constant ETHEREUM_WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  address internal constant OPTIMISM_POOL_ADDRESS = 0x395Ae52bB17aef68C2888d941736A71dC6d4e125;
  address internal constant OPTIMISM_USDC_ADDRESS = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
  address internal constant OPTIMISM_WETH_ADDRESS = 0x4200000000000000000000000000000000000006;

  // Token decimals
  uint8 internal constant DEFAULT_TOKEN_DECIMAL = 18;
  uint8 internal constant USDC_TOKEN_DECIMAL = 6;

  // Token names and symbols
  string internal constant POOL_SYMBOL = "POOL";
  string internal constant USDC_SYMBOL = "USDC";
  string internal constant WETH_SYMBOL = "WETH";

  string internal constant PT_USDC_NAME = "PoolTogether Prize USD Coin";
  string internal constant PT_USDC_SYMBOL = "PTUSDC";

  string internal constant PT_WETH_NAME = "PoolTogether Prize Wrapped Ether";
  string internal constant PT_WETH_SYMBOL = "PTWETH";

  // Token prices
  uint256 internal constant USDC_PRICE = 100000000;
  uint256 internal constant ETH_PRICE = 170408610000;
  uint256 internal constant PRIZE_TOKEN_PRICE = 0.562709e18;

  // Vault
  uint256 internal constant YIELD_FEE_PERCENTAGE = 0; // 0%
  address internal constant YIELD_FEE_RECIPIENT = address(0);

  function _matches(string memory a, string memory b) internal pure returns (bool) {
    return keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b)));
  }

  function _getToken(string memory _tokenSymbol) internal view returns (address) {
    address _tokenAddress;

    if (block.chainid == ETHEREUM_CHAIN_ID) {
      if (_matches(_tokenSymbol, POOL_SYMBOL)) {
        _tokenAddress = ETHEREUM_POOL_ADDRESS;
      }

      if (_matches(_tokenSymbol, USDC_SYMBOL)) {
        _tokenAddress = ETHEREUM_USDC_ADDRESS;
      }

      if (_matches(_tokenSymbol, WETH_SYMBOL)) {
        _tokenAddress = ETHEREUM_WETH_ADDRESS;
      }
    } else if (block.chainid == OPTIMISM_CHAIN_ID) {
      if (_matches(_tokenSymbol, POOL_SYMBOL)) {
        _tokenAddress = OPTIMISM_POOL_ADDRESS;
      }

      if (_matches(_tokenSymbol, USDC_SYMBOL)) {
        _tokenAddress = OPTIMISM_USDC_ADDRESS;
      }

      if (_matches(_tokenSymbol, WETH_SYMBOL)) {
        _tokenAddress = OPTIMISM_WETH_ADDRESS;
      }
    }

    return _tokenAddress;
  }
}
