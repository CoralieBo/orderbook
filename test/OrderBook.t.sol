// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "../lib/forge-std/src/Test.sol";
import {OrderBook} from "../src/OrderBook.sol";
import {Token1} from "../src/Token1.sol";  // Assume Token1.sol is in src folder
import {Token2} from "../src/Token2.sol";  // Assume Token2.sol exists too

contract OrderBookTest is Test {
    OrderBook public orderBook;
    Token1 public token1;
    Token2 public token2;
    address public user1;
    address public user2;

    function setUp() public {
        // Deploy tokens
        token1 = new Token1();
        token2 = new Token2();

        // Deploy the OrderBook contract
        orderBook = new OrderBook(token1, token2);

        // Set up users
        user1 = address(0x1);
        user2 = address(0x2);

        // Mint tokens to users
        token1.transfer(user1, 1000 * 10 ** token1.decimals());
        token2.transfer(user2, 1000 * 10 ** token2.decimals());
    }

    function test_CreateBuyOrder() public {
        vm.startPrank(user1);

        // Approve token2 for the OrderBook
        token1.approve(address(orderBook), 100 * 1e18);

        // Create a buy order
        orderBook.createOrder(10, 10, false);

        // Check that the buy order is recorded
        OrderBook.Order[] memory sells = orderBook.getSells();
        assertEq(sells.length, 1);
        assertEq(sells[0].trader, user1);
        assertEq(sells[0].amount, 10);
        assertEq(sells[0].price, 10);
        assertFalse(sells[0].isBuyOrder);

        vm.stopPrank();
    }
}
