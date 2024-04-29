// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract RentProperty {
    uint256 public number;

    struct Property {
        uint id;
        string propertyAddress;
        string city;
        string country;
    }

    struct Contract {
        uint id;
        uint monthlyRent;
        uint deposit;
        uint paymentDue;
        uint gracePeriod;
        address lessor;
        address lease;
        uint startDate;
        uint endDate;
        bool isActive;
        uint period;
    }

    struct Payment {
        uint id;
        uint dueDate;
        bool paid;
    }

    mapping(uint => Contract) public contracts;
    // Contract id => contract payments id => payments
    // payments[contract_id][payments_id]
    mapping(uint => mapping(uint => Payment)) payments;
    uint contractCount;

    event RentPaid(
        address lease,
        uint contractId,
        uint paymentId,
        uint timestamp
    );

    event ContractTerminated(string reason);

    function payRent(uint contractId, uint paymentId) public payable {
        Contract memory _contract = contracts[contractId];

        require(msg.sender == _contract.lease, "Only lease can pay rent.");
        require(_contract.isActive, "Contact is not active.");
        require(msg.value == _contract.monthlyRent, "Incorrect rent value.");

        (bool sent, ) = _contract.lessor.call{value: msg.value}("");
        require(sent, "Failed to send rent.");

        payments[contractId][paymentId].paid = true;
        emit RentPaid(msg.sender, contractId, paymentId, block.timestamp);
    }

    function checkPaymentStatus(uint contractId) public {
        Contract memory _contract = contracts[contractId];
        Payment memory _payments = payments[contractId];

        require(
            msg.sender == _contract.lessor || msg.sender == _contract.lease,
            "Unauthorized access"
        );
        require(_contract.isActive, "Contract is not active.");
        for (uint i = 0; i < _contract.period; i++) {
            if (
                !_payments[i].paid &&
                block.timestamp > _payments[i].dueDate + _contract.gracePeriod
            ) {
                terminateContract(_contract, "Rent to paid on time");
            }
        }
    }

    function terminateContract(
        Contract memory _contract,
        string memory reason
    ) internal {
        _contract.isActive = false;
        emit ContractTerminated(reason);
    }
}
