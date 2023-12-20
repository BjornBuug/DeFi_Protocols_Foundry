pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./Interfaces/IWETH9.sol";
import "./Interfaces/IUni_Pair_V2.sol";


/** 
    Fork the Ethereum mainnet to simulate Flash swap using "Swap" function to borrow 500 WETH from the UniswapV2Pair UNI/WETH 
    pair in the UniswapV2 protocol
*/


contract UniswapV2FlashSwap is Test {

    WETH9 weth = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    Uni_Pair_V2 UniswapV2Pair = Uni_Pair_V2(0xd3d2E2692501A5c9Ca623199D38826e513033a17);

    function setUp() public {
        vm.createSelectFork("mainnet", 15012670); //fork mainnet at block number 15012670
    }

    function test_FlashSwap() public {
        weth.deposit{value: 100 ether}();
        Uni_Pair_V2(UniswapV2Pair).swap(0, 1000 * 1e18, address(this), "0x00");
    }


    function uniswapV2Call(
            address sender,
            uint256 amount0,
            uint256 amount1,
            bytes calldata data
    ) external {

        emit log_named_decimal_uint("Address(this) balance after flash borrowing",
                                     weth.balanceOf(address(this)), 18);

        // Calculate 0.3%
        uint256 fee = ((amount1 * 3) / 997) + 1;
        uint256 amountToPay = amount1 + fee;

        //Pay back the loan to the uniSwapV3
        weth.transfer(address(UniswapV2Pair), amountToPay);

        emit log_named_decimal_uint("Address(this) balance after paying back the loan",
                                     weth.balanceOf(address(this)), 18);
    }

    receive() external payable {}

}




