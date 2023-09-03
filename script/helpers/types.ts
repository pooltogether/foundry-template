export type Version = {
  major: number;
  minor: number;
  patch: number;
};

export type Contract = {
  chainId: number;
  address: string;
  version: Version;
  type: string;
  tokens?: VaultInfo[];
};

export type ContractList = {
  name: string;
  version: Version;
  timestamp: string;
  contracts: Contract[];
};

export type VaultExtensionValue = string | number | boolean | null | undefined;

export interface VaultExtensions {
  underlyingAsset: {
    address: `0x${string}`;
    symbol: string;
    name: string;
  };
  [key: string]:
    | {
        [key: string]:
          | {
              [key: string]: VaultExtensionValue;
            }
          | VaultExtensionValue;
      }
    | VaultExtensionValue;
}

export interface VaultInfo {
  chainId: number;
  address: `0x${string}`;
  name: string;
  decimals: number;
  symbol: string;
  extensions: VaultExtensions;
}

export interface VaultList {
  name: string;
  keywords?: string[];
  version: Version;
  timestamp: string;
  tokens: VaultInfo[];
}
