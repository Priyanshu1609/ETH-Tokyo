import React, { useState, useEffect } from "react";

import Review from "../components/Review";
import Main from "../components/Main";
import Complete from "../components/Complete";
import { ethers } from "ethers";

import BulkSwap from "../abis/BulkSwap.json";

const Home = () => {
  const [step, setStep] = useState(0);
  //       address _from,
  // address _to,
  //   uint256 _amount,
  //     address _fromToken,
  //       address _toToken,
  //         uint256 _toChain,
  //           uint32 destinationDomain,
  //             uint256 relayerFee

  const [data, setData] = useState([
    {
      _from: "",
      _to: "",
      _amount: "",
      _fromToken: "",
      _toToken: "",
      _toChain: "",
      _destinationDomain: "",
      _relayerFee: ""
    }
  ]);

  const onExecuteOrder = async (e) => {
    e.preventDefault();

    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();

      const contract = new ethers.Contract(
        "0xD81F22FfD56Eb0B6074f73C8Ed7F54A173a692A0",
        BulkSwap.abi,
        signer
      )

      let item = data[0];

      const tx = await contract.executeOrder(
        item._from,
        item._to,
        item._amount,
        item._fromToken,
        item._toToken,
        item._toChain,
        item._destinationDomain,
        item._relayerFee
      );

      await tx.wait();


    } catch (error) {
      console.error(error);
    }

  }

  return (
    <>
      {
        step === 0 ? (
          <Main />
        ) : step === 1 ? (
          <Review />
        ) : step === 2 ? (
          <Complete />
        ) : (
          <div>NOTHING</div>
        )
      }
    </>
  );
};

export default Home;
