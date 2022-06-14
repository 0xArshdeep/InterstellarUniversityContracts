// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/Contract.sol";
import "../lib/forge-std/src/Test.sol";

contract ContractTest is Test {
    Contract public myContract;

    function setUp() public {
        myContract = new Contract();
    }

    function testExample() public {
        assertTrue(true);
    }

    function testPublicMint() public {
        assertTrue(true);
    }

    function testWhitelistMint() public {
        assertTrue(true);
    }
}
