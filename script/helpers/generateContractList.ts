import * as fs from "fs";
import { ethers } from "ethers";
import npmPackage from "../../package.json";

import { Contract, ContractList, VaultInfo, VaultList, Version } from "./types";

const { Interface } = ethers;

const versionSplit = npmPackage.version.split(".");
const patchSplit = versionSplit[2].split("-");

const PACKAGE_VERSION: Version = {
  major: Number(versionSplit[0]),
  minor: Number(versionSplit[1]), // Beta version
  patch: Number(patchSplit[0]),
};

// Chain IDs
const ETHEREUM_CHAIN_ID = 1;
const OPTIMISM_CHAIN_ID = 10;

// Token addresses
const ETHEREUM_USDC_ADDRESS = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const ETHEREUM_WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

const OPTIMISM_USDC_ADDRESS = "0x7F5c764cBc14f9669B88837ca1490cCa17c31607";
const OPTIMISM_WETH_ADDRESS = "0x4200000000000000000000000000000000000006";

// Token decimals
const DEFAULT_DECIMALS = 18;
const USDC_DECIMALS = 6;

// Token names and symbols
const USDC_NAME = "USD Coin";
const USDC_SYMBOL = "USDC";

const WETH_NAME = "Wrapped Ether";
const WETH_SYMBOL = "WETH";

const PT_USDC_NAME = "PoolTogether Prize USD Coin";
const PT_USDC_SYMBOL = "PTUSDC";

const PT_WETH_NAME = "PoolTogether Prize Wrapped Ether";
const PT_WETH_SYMBOL = "PTWETH";

// Factories deploy data
const aaveV3YieldVaultFactoryDeployData = {
  [OPTIMISM_USDC_ADDRESS]:
    "0xabeccaa40000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c31607",
  [OPTIMISM_WETH_ADDRESS]:
    "0xabeccaa40000000000000000000000004200000000000000000000000000000000000006",
};

const vaultFactoryDeployData = {
  [OPTIMISM_USDC_ADDRESS]:
    "0xbfc49da30000000000000000000000007f5c764cbc14f9669b88837ca1490cca17c31607000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000001800000000000000000000000000d51a33975024e8afc55fde9f6b070c10aa71dd9000000000000000000000000964356cecf4f4679cab76d969c043fcccaafe3070000000000000000000000008cfffffa42407db9dcb974c2c744425c3e58d83200000000000000000000000047b55748243314be6a341668ecda2066c0625f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c516fe1fee5122d66e9427721a63d6c27e1201ca000000000000000000000000000000000000000000000000000000000000001b506f6f6c546f676574686572205072697a652055534420436f696e000000000000000000000000000000000000000000000000000000000000000000000000065054555344430000000000000000000000000000000000000000000000000000",
  [OPTIMISM_WETH_ADDRESS]:
    "0xbfc49da30000000000000000000000004200000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000001800000000000000000000000000d51a33975024e8afc55fde9f6b070c10aa71dd9000000000000000000000000dc1056cd48a46ee001faf851e50e83fb77c6f3c90000000000000000000000008cfffffa42407db9dcb974c2c744425c3e58d83200000000000000000000000047b55748243314be6a341668ecda2066c0625f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c516fe1fee5122d66e9427721a63d6c27e1201ca0000000000000000000000000000000000000000000000000000000000000020506f6f6c546f676574686572205072697a65205772617070656420457468657200000000000000000000000000000000000000000000000000000000000000065054574554480000000000000000000000000000000000000000000000000000",
};

export const rootFolder = `${__dirname}/../..`;

const getAbi = (type: string) =>
  JSON.parse(fs.readFileSync(`${rootFolder}/out/${type}.sol/${type}.json`, "utf8")).abi;

const getBlob = (path: string) => JSON.parse(fs.readFileSync(`${path}/run-latest.json`, "utf8"));

const getUnderlyingAsset = (chainId: number, underlyingAssetAddress: string) => {
  let name: string;
  let symbol: string;
  let decimals: number;

  if (chainId === ETHEREUM_CHAIN_ID) {
    if (underlyingAssetAddress === ETHEREUM_USDC_ADDRESS) {
      name = USDC_NAME;
      symbol = USDC_SYMBOL;
      decimals = USDC_DECIMALS;
    }

    if (underlyingAssetAddress === ETHEREUM_WETH_ADDRESS) {
      name = WETH_NAME;
      symbol = WETH_SYMBOL;
      decimals = DEFAULT_DECIMALS;
    }
  }

  if (chainId === OPTIMISM_CHAIN_ID) {
    if (underlyingAssetAddress === OPTIMISM_USDC_ADDRESS) {
      name = USDC_NAME;
      symbol = USDC_SYMBOL;
      decimals = USDC_DECIMALS;
    }

    if (underlyingAssetAddress === OPTIMISM_WETH_ADDRESS) {
      name = WETH_NAME;
      symbol = WETH_SYMBOL;
      decimals = DEFAULT_DECIMALS;
    }
  }

  return {
    name,
    symbol,
    decimals,
  };
};

const generateVaultInfo = (
  chainId: number,
  address: `0x${string}`,
  underlyingAssetAddress: `0x${string}`,
  name: string,
  symbol: string
): VaultInfo => {
  const underlyingAsset = getUnderlyingAsset(chainId, underlyingAssetAddress);

  return {
    chainId,
    address,
    name,
    decimals: underlyingAsset.decimals,
    symbol,
    extensions: {
      underlyingAsset: {
        address: underlyingAssetAddress,
        symbol: underlyingAsset.symbol,
        name: underlyingAsset.name,
      },
    },
  };
};

const formatContract = (
  chainId: number,
  name: string,
  address: `0x${string}`,
  transactionData: any
): Contract => {
  const regex = /V[1-9+]((.{0,2}[0-9+]){0,2})$/g;
  const version = name.match(regex)?.[0]?.slice(1).split(".") || [1, 0, 0];
  const type = name.split(regex)[0];

  const defaultContract = {
    chainId,
    address,
    version: {
      major: Number(version[0]),
      minor: Number(version[1]) || 0,
      patch: Number(version[2]) || 0,
    },
    type,
    abi: getAbi(type),
  };

  if (type === "Vault") {
    const { underlyingAssetAddress, name, symbol } = getVaultInfos(transactionData);

    return {
      ...defaultContract,
      tokens: [generateVaultInfo(chainId, address, underlyingAssetAddress, name, symbol)],
    };
  } else {
    return defaultContract;
  }
};

export const generateContractList = (deploymentPaths: string[]): ContractList => {
  const contractList: ContractList = {
    name: "Hyperstructure Mainnet",
    version: PACKAGE_VERSION,
    timestamp: new Date().toISOString(),
    contracts: [],
  };

  // Map to reference deployed contract names by address
  const contractAddressToName = new Map<string, string>();

  deploymentPaths.forEach((deploymentPath) => {
    const deploymentBlob = getBlob(deploymentPath);
    const chainId = deploymentBlob.chain;
    const transactions = deploymentBlob.transactions;

    transactions.forEach(
      ({
        transactionType,
        contractName,
        contractAddress,
        arguments: deployArguments,
        transaction,
        additionalContracts,
      }) => {
        const createdContract = additionalContracts[0];

        // Store name of contract for reference later
        if (contractName) contractAddressToName.set(contractAddress, contractName);

        if (transactionType == "CALL") {
          // If `createdContract` is not empty, it means that a contract was created
          if (createdContract) {
            // Handle case when contract name isn't available on CALL
            if (!contractName) {
              const storedName = contractAddressToName.get(contractAddress);
              if (storedName) contractName = storedName;
            }

            if (createdContract.transactionType === "CREATE2") {
              Object.keys(aaveV3YieldVaultFactoryDeployData).forEach((key) => {
                if (transaction.data === aaveV3YieldVaultFactoryDeployData[key]) {
                  contractName = "AaveV3ERC4626";
                }
              });

              Object.keys(vaultFactoryDeployData).forEach((key) => {
                if (transaction.data === vaultFactoryDeployData[key]) {
                  contractName = "Vault";
                }
              });
            }

            if (contractName === "LiquidationPairFactory") {
              contractName = "LiquidationPair";
            }

            contractAddress = createdContract.address;
            transactionType = "CREATE";
          }
        }

        if (transactionType === "CREATE") {
          contractList.contracts.push(
            formatContract(chainId, contractName, contractAddress, transaction.data)
          );
        }
      }
    );
  });

  return contractList;
};

export const getVaultInfos = (transactionData: any) => {
  let underlyingAssetAddress: `0x${string}`;
  let name: string;
  let symbol: string;

  if (transactionData === vaultFactoryDeployData[OPTIMISM_USDC_ADDRESS]) {
    underlyingAssetAddress = OPTIMISM_USDC_ADDRESS;
    name = PT_USDC_NAME;
    symbol = PT_USDC_SYMBOL;
  }

  if (transactionData === vaultFactoryDeployData[OPTIMISM_WETH_ADDRESS]) {
    underlyingAssetAddress = OPTIMISM_WETH_ADDRESS;
    name = PT_WETH_NAME;
    symbol = PT_WETH_SYMBOL;
  }

  return { underlyingAssetAddress, name, symbol };
};

export const generateVaultList = (vaultDeploymentPath: string): VaultList => {
  const vaultList: VaultList = {
    name: "PoolTogether Mainnet Vault List",
    keywords: ["pooltogether"],
    version: PACKAGE_VERSION,
    timestamp: new Date().toISOString(),
    tokens: [],
  };

  const vaultDeploymentBlob = getBlob(vaultDeploymentPath);
  const chainId = vaultDeploymentBlob.chain;
  const vaultTransactions = vaultDeploymentBlob.transactions;

  vaultTransactions.forEach(
    ({ transactionType, contractName, transaction, additionalContracts }) => {
      if (transactionType === "CALL") {
        const createdContract = additionalContracts[0];

        if (createdContract && createdContract.transactionType === "CREATE2") {
          const { underlyingAssetAddress, name, symbol } = getVaultInfos(transaction.data);

          vaultList.tokens.push(
            generateVaultInfo(
              chainId,
              createdContract.address,
              underlyingAssetAddress,
              name,
              symbol
            )
          );
        }
      }
    }
  );

  return vaultList;
};

export const writeList = (list: ContractList | VaultList, folderName: string, fileName: string) => {
  const dirpath = `${rootFolder}/${folderName}`;

  fs.mkdirSync(dirpath, { recursive: true });
  fs.writeFile(`${dirpath}/${fileName}.json`, JSON.stringify(list), (err) => {
    if (err) {
      console.error(err);
      return;
    }
  });
};
