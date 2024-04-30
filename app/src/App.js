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
  const [newProperty, setNewProperty] = useState();
  const [newRentContract, setNewRentContract] = useState();
  const [contractId, setContractId] = useState();
  const [propertyId, setPropertyId] = useState();
  const [contract, setContract] = useState();
  const [property, setProperty] = useState();
  const [signContractId, setSignContractId] = useState();
  const [payRentObject, setPayRentObject] = useState();
  const [approveRent, setApproveRent] = useState();

  const setValue = (setter) => (evt) => setter(evt.target.value);
  const _setNewProperty = (name) => (evt) =>
    setNewProperty({ ...newProperty, [name]: evt.target.value });
  const setRentContract = (name) => (evt) =>
    setNewRentContract({ ...newRentContract, [name]: evt.target.value });
  const _setPayRentObject = (name) => (evt) =>
    setPayRentObject({ ...payRentObject, [name]: evt.target.value });

  const _setApproveRent = (name) => (evt) =>
    setApproveRent({ ...approveRent, [name]: evt.target.value });

  useEffect(() => {
    async function getSinger() {
      const accounts = await provider.send("eth_requestAccounts", []);

      setAccount(accounts[0]);
      setSigner(provider.getSigner());
    }

    getSinger();
  }, [account]);

  const RentPropertyContract = new ethers.Contract(
    CONTRACT_ADDRESS,
    RentProperty.abi,
    provider
  );
  const contractWithSigner = RentPropertyContract.connect(signer);

  async function getContractCount() {
    const _contractCount = parseInt(
      (await contractWithSigner.contractCount())._hex
    );
    setContractCount(_contractCount);
    console.log("_contractCount: ", _contractCount);
  }

  async function getPropertiesCount() {
    const _propertiesCount = parseInt(
      (await contractWithSigner.propertiesCount())._hex
    );
    setPropertiesCount(_propertiesCount);

    console.log("_propertiesCount: ", _propertiesCount);
  }

  useEffect(() => {
    async function fetchData() {
      getContractCount();
      getPropertiesCount();
    }
    fetchData();
  }, [signer]);

  async function listProperty() {
    console.log("newProperty", newProperty);
    const property = await contractWithSigner.listPropertyForRent(
      newProperty.id,
      newProperty.propertyAddress,
      newProperty.city,
      newProperty.country,
      newProperty.description
    );
    console.log("property: ", property);
  }

  async function createRentContract() {
    console.log("newRentContract: ", newRentContract);
    const property = await contractWithSigner.createRentContract(
      newRentContract.id,
      newRentContract.lessor,
      newRentContract.lease,
      newRentContract.monthlyRent,
      newRentContract.deposit,
      newRentContract.paymentDue,
      newRentContract.gracePeriod,
      newRentContract.startDate,
      newRentContract.endDate,
      newRentContract.period,
      newRentContract.propertyId
    );
  }

  async function getContractById() {
    const _contract = await contractWithSigner.getContractById(contractId);
    console.log("_contract: ", _contract);
    const payments = [];
    for (let i = 0; i < _contract.period; i++) {
      const _payment = await contractWithSigner.payments(contractId, i);
      console.log("_payment: ", _payment);
      payments.push(_payment);
    }
    setContract({ ..._contract, payments: payments });
  }

  async function getPropertyById() {
    const _property = await contractWithSigner.getPropertyById(propertyId);
    console.log("_property: ", _property);
    setProperty(_property);
  }

  async function signContract() {
    await contractWithSigner.signContract(signContractId);
  }

  async function payRent() {
    console.log("payRentObject: ", payRentObject);
    await contractWithSigner.payRent(
      payRentObject.contractId,
      payRentObject.paymentId,
      { value: payRentObject.value }
    );
  }

  async function approveRentReceived() {
    console.log("approveRent: ", approveRent);
    await contractWithSigner.approveRentReceived(
      approveRent.contractId,
      approveRent.paymentId
    );
  }

  return (
    <div className="appContainer">
      <h1>Rent Property dApp</h1>
      <h2>What's this dApp about?</h2>
      <div className="description">add later</div>
      <div className="contractContainer">
        <div className="contract">
          <h2>Properties</h2>
          <div>Properties count: {propertiesCount}</div>
        </div>
        <div className="contract">
          <h2>Contracts</h2>
          <div>Contracts count: {contractCount}</div>
        </div>

        <div className="contract">
          <h2>List Property</h2>
          <label>
            ID
            <input
              type="text"
              id="id"
              value={newProperty?.id}
              onChange={_setNewProperty("id")}
            />
          </label>

          <label>
            Property Address
            <input
              type="text"
              id="propertyAddress"
              value={newProperty?.propertyAddress}
              onChange={_setNewProperty("propertyAddress")}
            />
          </label>

          <label>
            City
            <input
              type="text"
              id="city"
              value={newProperty?.city}
              onChange={_setNewProperty("city")}
            />
          </label>

          <label>
            Country
            <input
              type="text"
              id="country"
              value={newProperty?.country}
              onChange={_setNewProperty("country")}
            />
          </label>

          <label>
            Description
            <input
              type="text"
              id="description"
              value={newProperty?.description}
              onChange={_setNewProperty("description")}
            />
          </label>

          <div
            className="button"
            onClick={(e) => {
              e.preventDefault();
              listProperty();
            }}
          >
            List property
          </div>
        </div>

        <div className="contract">
          <h2>Create Rent Contract</h2>
          <label>
            ID
            <input
              type="text"
              id="id"
              value={newRentContract?.id}
              onChange={setRentContract("id")}
            />
          </label>

          <label>
            Lessor
            <input
              type="text"
              id="lessor"
              value={newRentContract?.lessor}
              onChange={setRentContract("lessor")}
            />
          </label>

          <label>
            Lease
            <input
              type="text"
              id="lease"
              value={newRentContract?.lease}
              onChange={setRentContract("lease")}
            />
          </label>

          <label>
            Monthly Rent
            <input
              type="text"
              id="monthlyRent"
              value={newRentContract?.monthlyRent}
              onChange={setRentContract("monthlyRent")}
            />
          </label>

          <label>
            Deposit
            <input
              type="text"
              id="deposit"
              value={newRentContract?.deposit}
              onChange={setRentContract("deposit")}
            />
          </label>

          <label>
            Payment Due
            <input
              type="text"
              id="paymentDue"
              value={newRentContract?.paymentDue}
              onChange={setRentContract("paymentDue")}
            />
          </label>

          <label>
            Grace Period
            <input
              type="text"
              id="gracePeriod"
              value={newRentContract?.gracePeriod}
              onChange={setRentContract("gracePeriod")}
            />
          </label>

          <label>
            Start Date
            <input
              type="text"
              id="startDate"
              value={newRentContract?.startDate}
              onChange={setRentContract("startDate")}
            />
          </label>

          <label>
            End Date
            <input
              type="text"
              id="endDate"
              value={newRentContract?.endDate}
              onChange={setRentContract("endDate")}
            />
          </label>

          <label>
            Period
            <input
              type="text"
              id="period"
              value={newRentContract?.period}
              onChange={setRentContract("period")}
            />
          </label>

          <label>
            Property ID
            <input
              type="text"
              id="propertyId"
              value={newRentContract?.propertyId}
              onChange={setRentContract("propertyId")}
            />
          </label>

          <div
            className="button"
            onClick={(e) => {
              e.preventDefault();
              createRentContract();
            }}
          >
            Create Contract
          </div>
        </div>

        <div className="contract">
          <h2>Get property by ID</h2>
          <label>
            Property ID
            <input
              type="text"
              id="propertyId"
              value={propertyId}
              onChange={setValue(setPropertyId)}
            />
          </label>

          <div
            className="button"
            onClick={(e) => {
              e.preventDefault();
              getPropertyById();
            }}
          >
            Get Property
          </div>

          {property ? (
            <div>
              <div>ID: {parseInt(property.id._hex)}</div>
              <div>Address: {property.propertyAddress}</div>
              <div>City: {property.city}</div>
              <div>Country: {property.country}</div>
              <div>Description: {property.description}</div>
            </div>
          ) : null}
        </div>

        <div className="contract">
          <h2>Get contract by ID</h2>
          <label>
            Contract ID
            <input
              type="text"
              id="contractId"
              value={contractId}
              onChange={setValue(setContractId)}
            />
          </label>

          <div
            className="button"
            onClick={(e) => {
              e.preventDefault();
              getContractById();
            }}
          >
            Get Contract
          </div>

          {contract ? (
            <div>
              <div>ID: {parseInt(contract.id._hex)}</div>
              <div>Lessor: {contract.lessor}</div>
              <div>Lease: {contract.lease}</div>
              <div>Monthly rent: {parseInt(contract.monthlyRent._hex)}</div>
              <div>Period: {parseInt(contract.period._hex)}</div>
              <div>Active: {contract.isActive ? "Yes" : "No"}</div>
              <h3>Payments</h3>
              {contract.payments
                ? contract.payments.map((payment) => (
                    <div>
                      <div>ID: {parseInt(payment.id._hex)}</div>
                      <div>Paid: {payment.paid? 'Yes' : 'No'}</div>
                      <div>Approved: {payment.approved? 'Yes' : 'No'}</div>
                    </div>
                  ))
                : null}
            </div>
          ) : null}
        </div>

        <div className="contract">
          <h2>Sign Contract</h2>
          <label>
            Contract ID
            <input
              type="text"
              id="signContractId"
              value={signContractId}
              onChange={setValue(setSignContractId)}
            />
          </label>

          <div
            className="button"
            onClick={(e) => {
              e.preventDefault();
              signContract();
            }}
          >
            Sign Contract
          </div>
        </div>

        <div className="contract">
          <h2>Pay Rent</h2>
          <label>
            Contract ID
            <input
              type="text"
              id="contractId"
              value={payRentObject?.contractId}
              onChange={_setPayRentObject("contractId")}
            />
          </label>

          <label>
            Payment ID
            <input
              type="text"
              id="paymentId"
              value={payRentObject?.paymentId}
              onChange={_setPayRentObject("paymentId")}
            />
          </label>

          <label>
            Value
            <input
              type="text"
              id="value"
              value={payRentObject?.value}
              onChange={_setPayRentObject("value")}
            />
          </label>

          <div
            className="button"
            onClick={(e) => {
              e.preventDefault();
              payRent();
            }}
          >
            Pay Rent
          </div>
        </div>

        <div className="contract">
          <h2>Approve Rent Received</h2>
          <label>
            Contract ID
            <input
              type="text"
              id="contractId"
              value={approveRent?.contractId}
              onChange={_setApproveRent("contractId")}
            />
          </label>

          <label>
            Payment ID
            <input
              type="text"
              id="paymentId"
              value={approveRent?.paymentId}
              onChange={_setApproveRent("paymentId")}
            />
          </label>

          <div
            className="button"
            onClick={(e) => {
              e.preventDefault();
              approveRentReceived();
            }}
          >
            Approve Rent Received
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
