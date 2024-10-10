// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract OrderBook {

    struct Order {
        address trader;
        uint256 amount;
        uint256 price; // Price per token in the other ERC20 token
        bool isBuyOrder;
        // bool isFilled;
    }

    IERC20 public token1;
    IERC20 public token2;

    Order[] private buys;
    Order[] private sells;
    Order[] private history;

    uint256 public orderCount;

    event NewOrder(uint256 indexed orderId, address indexed trader, uint256 amount, uint256 price, bool isBuyOrder);
    event OrderFilled(uint256 indexed orderId, address indexed trader);

    constructor(IERC20 _token1, IERC20 _token2) {
        token1 = _token1;
        token2 = _token2;
        orderCount = 0;
    }

    function createOrder(uint256 _amount, uint256 _price, bool _isBuyOrder) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_price > 0, "Price must be greater than 0");

        if(_isBuyOrder){
            createBuyOrder(_amount, _price);
        } else {
            createSellOrder(_amount, _price);
        }

        orderCount++;
    }

    function createBuyOrder(uint256 _amount, uint256 _price) internal {

        uint256 totalCost = _amount * _price;

        uint length = sells.length;
        bool isExecuted = false;
        for (uint i = 0; i < length; i++){
            Order memory sell = sells[i];
            if(sell.amount == _amount && sell.price == _price){
                history.push(Order({
                    trader: msg.sender,
                    amount: _amount,
                    price: _price,
                    isBuyOrder: true
                }));
                history.push(Order({
                    trader: sell.trader,
                    amount: sell.amount,
                    price: sell.price,
                    isBuyOrder: false
                }));
                sells[i] = sells[length - 1];
                sells.pop();
                require(token2.transferFrom(msg.sender, sell.trader, totalCost), "Payment transfer failed");
                require(token1.transfer(msg.sender, _amount), "Payment transfer failed");
                isExecuted = true;
                break;
            }
        }
        if(!isExecuted){
            buys.push(Order({
                trader: msg.sender,
                amount: _amount,
                price: _price,
                isBuyOrder: true
            }));
            require(token2.transferFrom(msg.sender, address(this), totalCost), "Payment failed");
        }

        emit NewOrder(orderCount, msg.sender, _amount, _price, true);
    }

    function createSellOrder(uint256 _amount, uint256 _price) internal {
        uint256 totalCost = _amount * _price;

        uint length = sells.length;
        bool isExecuted = false;
        for (uint i = 0; i < length; i++){
            Order memory buy = buys[i];
            if(buy.amount == _amount && buy.price == _price){
                history.push(Order({
                    trader: msg.sender,
                    amount: _amount,
                    price: _price,
                    isBuyOrder: true
                }));
                history.push(Order({
                    trader: buy.trader,
                    amount: buy.amount,
                    price: buy.price,
                    isBuyOrder: false
                }));
                sells[i] = sells[length - 1];
                sells.pop();
                require(token1.transferFrom(msg.sender, buy.trader, totalCost), "Payment transfer failed");
                require(token2.transfer(msg.sender, _amount), "Payment transfer failed");
                isExecuted = true;
                break;
            }
        }
        if(!isExecuted){
            sells.push(Order({
                trader: msg.sender,
                amount: _amount,
                price: _price,
                isBuyOrder: false
            }));
            require(token1.transferFrom(msg.sender, address(this), _amount), "Asset transfer failed");
        }
        emit NewOrder(orderCount, msg.sender, _amount, _price, false);
    }

    function getBuys() external view returns (Order[] memory) {
        return buys;
    }

    function getSells() external view returns (Order[] memory) {
        return sells;
    }

    function getHistory() external view returns (Order[] memory) {
        return history;
    }
}
