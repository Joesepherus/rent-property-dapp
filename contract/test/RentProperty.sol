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
            12
        );
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

    function test_signContract() public {
        vm.prank(leaseAddress);
        rentProperty.signContract(0);

        vm.prank(lessorAddress);
        rentProperty.signContract(0);
        bool signed = rentProperty.isContractSigned(0);
        assertEq(signed, true);
    }
}
