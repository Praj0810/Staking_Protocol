//SPDX-License-Identifier: MIT

pragma solidity 0.8.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20{

    constructor() ERC20("Reward Token","RT"){}

    function mint() public  {
        _mint(msg.sender, 1000 * 10 ** 18);
    }

}