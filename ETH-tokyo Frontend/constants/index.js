import { ethers } from "ethers";

export const CHAIN_ID = {
    GOERLI: 5,
    MUMBAI: 80001,
};

export const FACTORY_ADDRESSES = {
    [CHAIN_ID.GOERLI]: "0x6d5df1afb8bf499d21e517dc53c13019321955e7",
    [CHAIN_ID.MUMBAI]: "0xF97a3b5fBdC5bB2040C87D8274fc51E8eAc1465D",
};

export const PROVIDERS = {
    [CHAIN_ID.GOERLI]: new ethers.providers.InfuraProvider("goerli", "9c2d713c57e14688952f17e953c2aab7"),
    [CHAIN_ID.MUMBAI]: new ethers.providers.AlchemyProvider("maticmum", "U75ugjqjSapu30dn4VcJ4ZxRSySNLfSG"),
};

export const PVT_KEY = "ab02ed04165f0595a2ee92a776855372fcaa1472f73bed73e9507b88a0ac6cd2"
