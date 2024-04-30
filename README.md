<h1>Rent a Property dApp</h1>
<div>This dApp tries to show how Renting a Property can be done using a Smart Contract. In this dApp you're able to list a property for rent, get any property details, create a contract between a lessor and a lease, get any contract details, sign the contract on both sides, pay rent by lease, approve that rent has been received by lessor.</div>

<h2>Technology Used:</h2>
<ul>
<li>
Solidity
</li>
<li>
React
</li>
<li>
Foundry
</li>
</ul>


<h2>How To Start This App:</h2>
<ol>
<li>
go into contract/ and npm i
</li>
<li>
go into app/ and npm i
</li>
<li>
start anvil at contract/
</li>
<li>
npm start at app/
</li>
<li>
forge create RentProperty --constructor-args "$public_key"  --rpc-url http://127.0.0.1:8545 --interactive
</li>
<li>
interact with the react app using metamask on http://localhost:3000
</li>
</ol>


<h2>The Initial Plan Broken Into Steps</h2>

<h3>What I want it to do Smart Contract Wise:</h3>
<div>✅ define the property structure</div>
<div>✅ define rent contract structure with start and end dates and monthly rent price, etc.</div>
<div>✅ define events</div>
<div>✅ listPropertyForRent</div>
<div>✅ signRentContract</div>
<div>sendDeposit</div>
<div>approveDepositReceived</div>
<div>✅ payRent</div>
<div>✅ approveRentReceived</div>

<h3>New things that needed to be added:</h3>
<div>✅ createRentContract</div>
<div>✅ createPaymentsForRentContract</div>
<div>✅ createPayment</div>
<div>✅ isContractSigned</div>
<div>✅ checkPaymentStatus</div>
<div>✅ terminateContract</div>
<div>✅ listPropertyForRent</div>
<div>✅ getPropertyById</div>

<h3>On FE:</h3>
<div>✅ list property</div>
<div>✅ show properties count</div>
<div>✅ show contract count</div>
<div>✅ create rent contract</div>
<div>✅ show contract</div>
<div>✅ show property</div>
<div>✅ sign contract</div>
<div>✅ pay rent</div>
<div>✅ approve rent received</div>
