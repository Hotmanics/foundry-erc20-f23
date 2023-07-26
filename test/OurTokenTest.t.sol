// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("Bob");
    address alice = makeAddr("Alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    // Additional test cases
    function testInitialSupply() public {
        uint256 totalSupply = ourToken.totalSupply();
        assertEq(
            totalSupply,
            STARTING_BALANCE,
            "Total supply should be equal to the initial supply"
        );
    }

    function testNameAndSymbol() public {
        string memory expectedName = "OurToken";
        string memory expectedSymbol = "OT";

        string memory name = ourToken.name();
        string memory symbol = ourToken.symbol();

        assertEq(name, expectedName, "Token name should match");
        assertEq(symbol, expectedSymbol, "Token symbol should match");
    }

    function testTransfer() public {
        uint256 transferAmount = 2 ether;

        // Perform a transfer from Bob to Alice
        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);

        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
    }

    function testApproveAndAllowance() public {
        uint256 initialAllowance = 1000;
        uint256 newAllowance = 500;

        // Bob approves Alice to spend some tokens on his behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        // Check the allowance of Alice for spending Bob's tokens
        uint256 allowance = ourToken.allowance(bob, alice);
        assertEq(allowance, initialAllowance);

        // Bob updates the allowance for Alice
        vm.prank(bob);
        ourToken.approve(alice, newAllowance);

        // Check the updated allowance of Alice for spending Bob's tokens
        uint256 updatedAllowance = ourToken.allowance(bob, alice);
        assertEq(updatedAllowance, newAllowance);
    }

    function testBurn() public {
        uint256 burnAmount = 3 ether;

        // Bob burns some of his tokens
        vm.prank(bob);
        ourToken.burn(burnAmount);

        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - burnAmount);
        assertEq(ourToken.totalSupply(), STARTING_BALANCE - burnAmount);
    }
}
