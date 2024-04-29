// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RentProperty} from "../src/RentProperty.sol";

contract RentPropertyTest is Test {
    RentProperty public rentProperty;
    uint256 constant firstContractId = 0;
    address constant lessorAddress = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address constant leaseAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {
        rentProperty = new RentProperty();

        rentProperty.listPropertyForRent(
            0,
            "Lincoln Street 8",
            "Washington",
            "USA",
            "Wonderful 3 bedroom property for rent."
        );

        RentProperty.Property memory _property = rentProperty.getPropertyById(
            0
        );

        rentProperty.createRentContract(
            firstContractId,
            lessorAddress,
            leaseAddress,
            500,
            1000,
            20,
            30,
            1,
            2,
            12,
            _property.id
        );
        vm.prank(leaseAddress);
        rentProperty.signContract(0);

        vm.prank(lessorAddress);
        rentProperty.signContract(0);

        vm.deal(leaseAddress, 1000 ether);
    }

    function test_CreateRentContract() public view {
        RentProperty.Contract memory _contract = rentProperty.getContractById(
            0
        );

        uint contractCount = rentProperty.contractCount();
        assertEq(contractCount, 1);
        assertEq(_contract.id, 0);
        assertEq(_contract.monthlyRent, 500);
    }

    function test_paymentsCreated() public view {
        RentProperty.Contract memory _contract = rentProperty.getContractById(
            0
        );

        for (uint i = 0; i < _contract.period; i++) {
            RentProperty.Payment memory _payment = rentProperty
                .getPaymentsByContractIdAndPaymentId(_contract.id, i);
            // assertEq(_payment.id, i);
            uint _dueDate = _contract.paymentDue * (i + 1);
            assertEq(_payment.dueDate, _contract.startDate + _dueDate);
        }
    }

    function test_payRent() public {
        uint contractId = 0;
        uint paymentId = 0;
        payRent(contractId, paymentId);
        RentProperty.Payment memory _payment = rentProperty
            .getPaymentsByContractIdAndPaymentId(contractId, paymentId);
        assertEq(_payment.paid, true);
    }

    function payRent(uint _contractId, uint _paymentId) private {
        RentProperty.Contract memory _contract = rentProperty.getContractById(
            _contractId
        );

        vm.prank(leaseAddress);
        rentProperty.payRent{value: _contract.monthlyRent}(
            _contractId,
            _paymentId
        );
    }

    function test_ApproveRentReceived() public {
        uint contractId = 0;
        uint paymentId = 0;
        payRent(contractId, paymentId);

        vm.prank(lessorAddress);
        rentProperty.approveRentReceived(0, 0);

        RentProperty.Payment memory _payment = rentProperty
            .getPaymentsByContractIdAndPaymentId(0, 0);

        assertEq(_payment.approved, true);
    }
}
