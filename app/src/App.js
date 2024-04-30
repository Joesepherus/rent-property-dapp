import { ethers } from "ethers";
import { useEffect, useState } from "react";
import RentProperty from "./artifacts/contracts/RentProperty.sol/RentProperty.json";

const provider = new ethers.providers.Web3Provider(window.ethereum);

const CONTRACT_ADDRESS = "0x5fbdb2315678afecb367f032d93f642f64180aa3";

function App() {
  const [account, setAccount] = useState();
  const [signer, setSigner] = useState();


  useEffect(() => {
    async function getSinger() {
      const accounts = await provider.send("eth_requestAccounts", []);

      setAccount(accounts[0]);
      setSigner(provider.getSigner());
    }

    getSinger();
  }, [account]);

  const contract = new ethers.Contract(
    CONTRACT_ADDRESS,
    RentProperty.abi,
    provider
  );
  const contractWithSigner = contract.connect(signer);



  async function getContractCount() {
    const _contractCount = parseInt(
      (await contractWithSigner.contractCount())._hex
    );
    console.log('_contractCount: ', _contractCount);
  }

  useEffect(() => {
    async function fetchData() {
      getContractCount()
    }
    fetchData();
  }, [signer]);

  return <div className="appContainer"></div>;
}

export default App;
