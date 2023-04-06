import React, { useState } from "react";
import { ethers } from "ethers";
import abi from "../abis/ERC_20.json"
// import { create, NxtpSdkConfig } from "@connext/nxtp-sdk";
//create context
export const AppContext = React.createContext();

//create provider
export const AppProvider = ({ children }) => {
  const [visible, setVisible] = useState(false);
  const [loading, setLoading] = useState(false);

  const context = {
    visible,
    setVisible,
    // getContract,
    loading,
    setLoading,
    // withdraw,
  };

  return (
    <AppContext.Provider value={context}>
      {children}
    </AppContext.Provider>
  );
}