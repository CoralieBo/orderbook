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

    function test_CreateOrder_Fail() public {
        vm.startPrank(user1);

        token1.approve(address(orderBook), 100 * 1e18);

        vm.expectRevert("Amount must be greater than 0");
        orderBook.createOrder(0, 1, false);

        vm.expectRevert("Price must be greater than 0");
        orderBook.createOrder(100, 0, false);

        vm.stopPrank();
    }

    function test_CreateBuyOrder_Success() public {
        vm.startPrank(user1);

        token1.approve(address(orderBook), 100 * 1e18);

        orderBook.createOrder(100, 1, false);

        OrderBook.Order[] memory sells = orderBook.getSells();
        assertEq(sells.length, 1);
        assertEq(sells[0].trader, user1);
        assertEq(sells[0].amount, 100);
        assertEq(sells[0].price, 1);
        assertFalse(sells[0].isBuyOrder);

        vm.stopPrank();
    }

    function test_CreateSellOrder_Success() public {
        vm.startPrank(user2);

        token2.approve(address(orderBook), 100 * 1e18);
 
        orderBook.createOrder(100, 1, true);

        OrderBook.Order[] memory buys = orderBook.getBuys();
        assertEq(buys.length, 1);
        assertEq(buys[0].trader, user2);
        assertEq(buys[0].amount, 100);
        assertEq(buys[0].price, 1);
        assertTrue(buys[0].isBuyOrder);

        vm.stopPrank();
    }

    function test_CreateSellAndBuyOrders_Success() public {

        vm.startPrank(user1);

        token1.approve(address(orderBook), 100 * 1e18);

        orderBook.createOrder(100, 1, false);

        OrderBook.Order[] memory sells = orderBook.getSells();
        assertEq(sells.length, 1);
        assertEq(sells[0].trader, user1);
        assertEq(sells[0].amount, 100);
        assertEq(sells[0].price, 1);
        assertFalse(sells[0].isBuyOrder);

        vm.stopPrank();

        vm.startPrank(user2);

        token2.approve(address(orderBook), 100 * 1e18);
 
        orderBook.createOrder(100, 1, true);

        OrderBook.Order[] memory history = orderBook.getHistory();
        assertEq(history.length, 2);
        assertEq(history[0].trader, user2);
        assertEq(history[1].trader, user1);
        assertEq(history[0].amount, 100);
        assertEq(history[1].amount, 100);
        assertEq(history[0].price, 1);
        assertEq(history[1].price, 1);
        assertTrue(history[0].isBuyOrder);
        assertFalse(history[1].isBuyOrder);

        OrderBook.Order[] memory buys = orderBook.getBuys();
        assertEq(buys.length, 0);
        OrderBook.Order[] memory sells2 = orderBook.getSells();
        assertEq(sells2.length, 0);

        vm.stopPrank();
    }

    function test_getOrderCount() public view {
        assertEq(orderBook.orderCount(), 0);
    }

}
