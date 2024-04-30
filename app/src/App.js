import { ethers } from "ethers";
import { useEffect, useState } from "react";
import RentProperty from "./artifacts/contracts/RentProperty.sol/RentProperty.json";

const provider = new ethers.providers.Web3Provider(window.ethereum);

const CONTRACT_ADDRESS = "0x5fbdb2315678afecb367f032d93f642f64180aa3";

function App() {
  const [account, setAccount] = useState();
  const [signer, setSigner] = useState();
  const [contractCount, setContractCount] = useState();
  const [propertiesCount, setPropertiesCount] = useState();

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
    setContractCount(_contractCount)
    console.log("_contractCount: ", _contractCount);
  }

  async function getPropertiesCount() {
    const _propertiesCount = parseInt(
      (await contractWithSigner.propertiesCount())._hex
    );
    setPropertiesCount(_propertiesCount)

    console.log("_propertiesCount: ", _propertiesCount);
  }

  useEffect(() => {
    async function fetchData() {
      getContractCount();
      getPropertiesCount();
    }
    fetchData();
  }, [signer]);

  return (
    <div className="appContainer">
      <h1>Rent Property dApp</h1>
      <h2>What's this dApp about?</h2>
      <div className="description">
        add later
      </div>
      <div className="contractContainer">
        <div className="contract">
          <h2>Contracts</h2>
          <div>Contracts count: {contractCount}</div>
        </div>
        <div className="contract">
          <h2>Properties</h2>
          <div>Properties count: {propertiesCount}</div>
        </div>
        
      </div>
    </div>
  );
}

export default App;
