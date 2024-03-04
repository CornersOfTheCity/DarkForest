// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import "forge-std/Test.sol";
import "./interface.sol";

interface GDSToken is IERC20 {
    function pureUsdtToToken(uint256 _uAmount) external returns (uint256);

    function lpPoolContract() external returns (address);
}

contract ContractTest is DSTest {
    address usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    address growAddress=0x0C9aD20802E89BeA858ae2E8594843fAfA887CB3;
    address grow_usdt_poolAddress = 0x2D2Af273117eE3639CDE46c8aF0baf447B8A1aEC;

    IERC20 USDT = IERC20(usdtAddress);
    IERC20 GROW = IERC20(growAddress);

    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        cheats.createSelectFork("bsc", 36_635_338);
        // cheats.label(address(GDS), "GDS");
        // cheats.label(address(USDT), "USDT");

    }

    function testClaim() public {
        console.log("before Collect:");
        console.log("GROW balance:", GROW.balanceOf(grow_usdt_poolAddress) / 1 ether);
        console.log("USDT balance:", USDT.balanceOf(grow_usdt_poolAddress) / 1 ether);

        cheats.createSelectFork("bsc",36_635_341);

        console.log("after Collect:");
        console.log("GROW balance:", GROW.balanceOf(grow_usdt_poolAddress)/ 1 ether);
        console.log("USDT balance:", USDT.balanceOf(grow_usdt_poolAddress)/ 1 ether);

        cheats.createSelectFork("bsc",36_635_353);

        console.log("after withdraw:");
        console.log("GROW balance:", GROW.balanceOf(grow_usdt_poolAddress)/ 1 ether);
        console.log("USDT balance:", USDT.balanceOf(grow_usdt_poolAddress)/ 1 ether);

        cheats.createSelectFork("bsc",36_635_882);

        console.log("after add:");
        console.log("GROW balance:", GROW.balanceOf(grow_usdt_poolAddress)/ 1 ether);
        console.log("USDT balance:", USDT.balanceOf(grow_usdt_poolAddress)/ 1 ether);

    }
}