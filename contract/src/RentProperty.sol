// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract RentProperty {
    struct Property {
        uint id;
        string propertyAddress;
        string city;
        string country;
    }

    struct Contract {
        uint id;
        address lessor;
        address lease;
        uint monthlyRent;
        uint deposit;
        uint paymentDue;
        uint gracePeriod;
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
    uint public contractCount = 0;

    event RentPaid(
        address lease,
        uint contractId,
        uint paymentId,
        uint timestamp
    );

    event ContractTerminated(
        uint contractId,
        uint paymentId,
        address lease,
        string reason
    );

    function createRentContract(
        uint _id,
        address _lessor,
        address _lease,
        uint _monthlyRent,
        uint _deposit,
        uint _paymentDue,
        uint _gracePeriod,
        uint _startDate,
        uint _endDate,
        uint _period
    ) public {
        Contract memory _contract = Contract(
            _id,
            _lessor,
            _lease,
            _monthlyRent,
            _deposit,
            _paymentDue,
            _gracePeriod,
            _startDate,
            _endDate,
            false,
            _period
        );
        contracts[contractCount] = _contract;
        contractCount++;
    }

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
        mapping(uint => Payment) storage _payments = payments[contractId];

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
                terminateContract(
                    contractId,
                    _payments[i].id,
                    "Rent to paid on time"
                );
            }
        }
    }

    function terminateContract(
        uint contractId,
        uint paymentId,
        string memory reason
    ) internal {
        Contract memory _contract = contracts[contractId];

        _contract.isActive = false;
        emit ContractTerminated(contractId, paymentId, _contract.lease, reason);
    }
}
