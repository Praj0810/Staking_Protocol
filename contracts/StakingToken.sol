//SPDX-License-Identifier: MIT

pragma solidity 0.8.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingToken is ERC20{

    constructor() ERC20("Staking Token","ST"){
    }
    
    function mint() public{
        _mint(msg.sender,1000 * 10 **18);
    }

   

}