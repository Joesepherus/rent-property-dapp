// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {RentProperty} from "../src/RentProperty.sol";

contract RentPropertyTest is Test {
    RentProperty public rentProperty;

    function setUp() public {
        rentProperty = new RentProperty();
    }

    function test_CreateRentContract() public {
        rentProperty.createRentContract(
            0,
            0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            0x70997970C51812dc3A010C7d01b50e0d17dc79C8,
            500,
            1000,
            20,
            30,
            1,
            2,
            12
        );
        RentProperty.Contract memory _contract = rentProperty.getContractById(0);

        uint contractCount = rentProperty.contractCount();
        assertEq(contractCount, 1);
        assertEq(_contract.id, 0);
        assertEq(_contract.monthlyRent, 500);
    }
    
}
