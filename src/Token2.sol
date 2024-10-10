// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Token2 is ERC20 {

    constructor() ERC20("Token2", "TK2") {
        _mint(msg.sender, 1000000 * (10 ** decimals()));
    }
}