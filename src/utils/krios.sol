// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract Krios is ERC20("Krios", "KRS") {


    
    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }
}
