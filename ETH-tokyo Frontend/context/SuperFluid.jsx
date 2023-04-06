import React, { useState, useEffect } from "react";
import { ethers } from "ethers";
import abi from "../abis/ERC_20.json"
// import { Framework } from "@superfluid-finance/sdk-core";

//create context
export const SuperFluidContext = React.createContext();

//create provider
export const SuperFluidProvider = ({ children }) => {

    const [flowRate, setFlowRate] = useState("");

    // function calculateFlowRate(amountInEther) {
    //     if (
    //         typeof Number(amountInEther) !== "number" ||
    //         isNaN(Number(amountInEther)) === true
    //     ) {
    //         console.log(typeof Number(amountInEther));
    //         alert("You can only calculate a flowRate based on a number");
    //         return;
    //     } else if (typeof Number(amountInEther) === "number") {
    //         const monthlyAmount = ethers.utils.parseEther(amountInEther.toString());
    //         const calculatedFlowRate = Math.floor(monthlyAmount / 3600 / 24 / 30);
    //         setFlowRate(calculatedFlowRate);
    //     }
    // }

    // //where the Superfluid logic takes place
    // async function createNewFlow(recipient, flowRate) {
    //     const provider = new ethers.providers.Web3Provider(window.ethereum);

    //     const signer = provider.getSigner();

    //     const chainId = await window.ethereum.request({ method: "eth_chainId" });


    //     const sf = await Framework.create({
    //         chainId: Number(chainId),
    //         provider: provider
    //     });

    //     const DAIxContract = await sf.loadSuperToken("fDAIx");
    //     const DAIx = "0xeDb95D8037f769B72AAab41deeC92903A98C9E16";
    //     // const DAIx = DAIxContract.address;

    //     try {
    //         const createFlowOperation = sf.cfaV1.createFlow({
    //             receiver: "0x560c7D1759b86E3EaD22dc2483AfC8cA67e1f3Ad",
    //             flowRate: 10000000000000,
    //             superToken: DAIx
    //             // userData?: string
    //         });

    //         console.log("Creating your stream...");

    //         const result = await createFlowOperation.exec(signer);
    //         console.log(result);

    //         console.log(
    //             `Congrats - you've just created a money stream!
    //             View Your Stream At: https://app.superfluid.finance/dashboard/${recipient}
    //             Network: Mumbai Testnet
    //             Super Token: Test Token
    //             Sender: 0x6d4b5acFB1C08127e8553CC41A9aC8F06610eFc7
    //             Receiver: ${recipient},
    //             FlowRate: ${flowRate}
    //             `
    //         );
    //     } catch (error) {
    //         console.log(
    //             "Hmmm, your transaction threw an error. Make sure that this stream does not already exist, and that you've entered a valid Ethereum address!"
    //         );
    //         console.error(error);
    //     }
    // }

    // // useEffect(() => {
    // //     createNewFlow("0x560c7D1759b86E3EaD22dc2483AfC8cA67e1f3Ad", 10000000000000);
    // // }, [])




    const context = {
        // flowRate,
        // calculateFlowRate,
        // createNewFlow
    };

    return (
        <SuperFluidContext.Provider value={context}>
            {children}
        </SuperFluidContext.Provider>
    );
}