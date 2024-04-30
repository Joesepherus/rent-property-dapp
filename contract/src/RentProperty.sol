// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract RentProperty {
    struct Property {
        uint id;
        string propertyAddress;
        string city;
        string country;
        address owner;
        string description;
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
        Property property;
    }

    struct Payment {
        uint id;
        uint dueDate;
        bool paid;
        bool approved;
    }

    mapping(uint => Property) properties;
    uint public propertiesCount = 0;

    // contract id => signer address
    mapping(uint => mapping(address => bool)) public contractSignatures;

    mapping(uint => Contract) public contracts;
    // Contract id => contract payments id => payments
    // payments[contract_id][payments_id]
    mapping(uint => mapping(uint => Payment)) public payments;
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

    event PropertyListedForRent(uint propertyId, address owner);

    event RentApproved(uint contractId, uint paymentId);
    event ContractSigned(uint contractId, address signer);
    event ContractActivated(uint contractId);
    event PaymentsForContractCreated(uint contractId);

    event ContractCreated(uint contractId);

    function getContractById(
        uint contractId
    ) public view returns (Contract memory) {
        Contract memory _contract = contracts[contractId];
        return _contract;
    }

    function getPaymentsByContractIdAndPaymentId(
        uint contractId,
        uint paymentId
    ) public view returns (Payment memory) {
        Payment memory _payments = payments[contractId][paymentId];
        return _payments;
    }

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
        uint _period,
        uint propertyId
    ) public {
        Property storage property = properties[propertyId];
        require(
            property.owner != address(0),
            "Property with that ID doesnt exist."
        );

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
            _period,
            property
        );
        contracts[contractCount] = _contract;
        emit ContractCreated(_contract.id);
        createPaymentsForRentContract(
            _period,
            _startDate,
            _paymentDue,
            contractCount
        );
        contractCount++;
    }

    function createPaymentsForRentContract(
        uint _period,
        uint _startDate,
        uint _paymentDue,
        uint _contractId
    ) internal {
        for (uint i = 0; i < _period; i++) {
            uint _dueDate = _paymentDue * (i + 1);
            Payment memory _payment = createPayment(i, _startDate + _dueDate);
            payments[_contractId][i] = _payment;
        }
        emit PaymentsForContractCreated(_contractId);
    }

    function createPayment(
        uint _id,
        uint _dueDate
    ) internal pure returns (Payment memory) {
        Payment memory _payment = Payment(_id, _dueDate, false, false);
        return _payment;
    }

    function signContract(uint contractId) public {
        Contract storage _contract = contracts[contractId];
        require(
            _contract.lessor == msg.sender || _contract.lease == msg.sender,
            "Signer has to be either lessor or lease."
        );
        require(
            !contractSignatures[contractId][msg.sender],
            "Contract is already signed by the signee."
        );
        contractSignatures[contractId][msg.sender] = true;

        emit ContractSigned(contractId, msg.sender);

        if (
            contractSignatures[contractId][_contract.lessor] &&
            contractSignatures[contractId][_contract.lease]
        ) {
            _contract.isActive = true;
            emit ContractActivated(contractId);
        }
    }

    function isContractSigned(uint contractId) public view returns (bool) {
        Contract memory _contract = contracts[contractId];
        return
            contractSignatures[contractId][_contract.lessor] &&
            contractSignatures[contractId][_contract.lease];
    }

    function payRent(uint contractId, uint paymentId) public payable {
        Contract memory _contract = contracts[contractId];
        Payment memory _payment = payments[contractId][paymentId];

        require(msg.sender == _contract.lease, "Only lease can pay rent.");
        require(_contract.isActive, "Contract is not active.");
        require(msg.value == _contract.monthlyRent, "Incorrect rent value.");
        require(msg.value == _contract.monthlyRent, "Incorrect rent value.");
        require(!_payment.paid, "This payment has already been paid for.");

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

    function approveRentReceived(uint _contractId, uint _paymentId) public {
        Contract memory _contract = contracts[_contractId];
        require(
            msg.sender == _contract.lessor,
            "Only lessor can approve rent being received."
        );

        Payment storage _payment = payments[_contractId][_paymentId];
        require(!_payment.approved, "Payment is already approved.");

        _payment.approved = true;
        emit RentApproved(_contractId, _paymentId);
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

    function listPropertyForRent(
        uint _id,
        string memory _propertyAddress,
        string memory _city,
        string memory _country,
        string memory _description
    ) public {
        Property memory _property = Property(
            _id,
            _propertyAddress,
            _city,
            _country,
            msg.sender,
            _description
        );
        properties[propertiesCount] = _property;
        propertiesCount++;
        emit PropertyListedForRent(_property.id, msg.sender);
    }

    function getPropertyById(
        uint propertyId
    ) public view returns (Property memory) {
        Property memory _property = properties[propertyId];
        return _property;
    }
}
