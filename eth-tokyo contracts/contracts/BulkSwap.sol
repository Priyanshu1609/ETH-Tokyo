// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

pragma abicoder v2;

import "../interfaces/OpsTaskCreator.sol";

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

interface WETH9_ {
    function deposit() external payable;

    function withdraw(uint wad) external;
}

import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "hardhat/console.sol";

contract BulkSwap is OpsTaskCreator {
    using SafeERC20 for IERC20;

    receive() external payable {}

    fallback() external payable {}

    IConnext public immutable connext;
    ISwapRouter public immutable swapRouter;

    uint24 public constant poolFee = 500;
    uint256 public out;
    address public constant WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;

    constructor(
        IConnext _connext,
        ISwapRouter _swapRouter,
        address payable _ops
    ) OpsTaskCreator(_ops, msg.sender) {
        connext = _connext;
        swapRouter = _swapRouter;
        owner = msg.sender;
    }

    function createTask(
        address _token,
        uint256 amountIn,
        address payable _recipient,
        uint256 _interval,
        uint256 _startTime
    ) internal returns (bytes32) {
        bytes memory execData = abi.encodeWithSelector(
            this.swapExactInputSingle.selector,
            _token,
            amountIn,
            _recipient
        );

        ModuleData memory moduleData = ModuleData({
            modules: new Module[](3),
            args: new bytes[](3)
        });

        moduleData.modules[0] = Module.TIME;
        moduleData.modules[1] = Module.PROXY;
        moduleData.modules[2] = Module.SINGLE_EXEC;

        moduleData.args[0] = _timeModuleArg(_startTime, _interval - 14400);
        moduleData.args[1] = _proxyModuleArg();
        moduleData.args[2] = _singleExecModuleArg();

        bytes32 id = _createTask(address(this), execData, moduleData, ETH);
        return id;
    }

    function swapExactInputSingle(
        address _token,
        uint256 amountIn,
        address payable _recipient
    ) external returns (uint256 amountOut) {
        TransferHelper.safeApprove(_token, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: _token,
                tokenOut: WETH,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);

        // address payable recipient  = payable(0x6d4b5acFB1C08127e8553CC41A9aC8F06610eFc7);
        WETH9_(WETH).withdraw(amountOut);
        _recipient.transfer(amountOut);
    }

    function xTransfer(
        address recipient,
        uint32 destinationDomain,
        address tokenAddress,
        uint256 amount,
        uint256 slippage,
        uint256 relayerFee
    ) external payable {
        IERC20 token = IERC20(tokenAddress);
        require(
            token.allowance(msg.sender, address(this)) >= amount,
            "User must approve amount"
        );

        // User sends funds to this contract
        token.transferFrom(msg.sender, address(this), amount);

        // This contract approves transfer to Connext
        token.approve(address(connext), amount);

        connext.xcall{value: relayerFee}(
            destinationDomain, // _destination: Domain ID of the destination chain
            recipient, // _to: address receiving the funds on the destination
            tokenAddress, // _asset: address of the token contract
            msg.sender, // _delegate: address that can revert or forceLocal on destination
            amount, // _amount: amount of tokens to transfer
            slippage, // _slippage: the maximum amount of slippage the user will accept in BPS
            "" // _callData: empty because we're only sending funds
        );
    }

    address public owner;
    uint256 public activeDepositCounter = 0;
    uint256 public inactiveDepositCounter = 0;
    uint256 private DepositCounter = 0;

    mapping(uint256 => address) public delDepositOf;
    mapping(uint256 => address) public authorOf;
    mapping(address => uint256) public DepositsOf;

    struct DepositStruct {
        uint256 DepositId;
        address from;
        address to;
        uint256 amount;
        address fromToken;
        address toToken;
        uint256 toChain;
        bool isActive;
        uint256 created;
        uint256 updated;
    }

    DepositStruct[] activeDeposits;
    DepositStruct[] inactiveDeposits;

    event Action(
        uint256 indexed DepositId,
        string indexed actionType,
        bool isActive,
        address indexed author,
        uint256 timestamp
    );

    modifier ownerOnly() {
        require(msg.sender == owner, "Owner reserved only");
        _;
    }

    function createDeposit(
        address _from,
        address _to,
        uint256 _amount,
        address _fromToken,
        address _toToken,
        uint256 _toChain
    ) external returns (bool) {
        DepositCounter++;
        authorOf[DepositCounter] = _from;
        DepositsOf[_from]++;
        activeDepositCounter++;

        activeDeposits.push(
            DepositStruct(
                DepositCounter,
                _from,
                _to,
                _amount,
                _fromToken,
                _toToken,
                _toChain,
                true,
                block.timestamp,
                block.timestamp
            )
        );

        emit Action(
            DepositCounter,
            "Deposit CREATED",
            true,
            _from,
            block.timestamp
        );

        return true;
    }

    // function updateDeposit(
    //     uint256 DepositId,
    //     address _to,
    //     uint256 _amount,
    //     address _fromToken,
    //     address _toToken
    // ) external returns (bool) {
    //     require(authorOf[DepositId] == msg.sender, "Unauthorized entity");

    //     for (uint i = 0; i < activeDeposits.length; i++) {
    //         if (activeDeposits[i].DepositId == DepositId) {
    //             activeDeposits[i].title = title;
    //             activeDeposits[i].description = description;
    //             activeDeposits[i].updated = block.timestamp;
    //         }
    //     }

    //     emit Action(
    //         DepositId,
    //         "Deposit UPDATED",
    //         Deactivated.NO,
    //         msg.sender,
    //         block.timestamp
    //     );

    //     return true;
    // }

    function showDeposit(
        uint256 DepositId
    ) external view returns (DepositStruct memory) {
        DepositStruct memory Deposit;
        for (uint i = 0; i < activeDeposits.length; i++) {
            if (activeDeposits[i].DepositId == DepositId) {
                Deposit = activeDeposits[i];
            }
        }
        return Deposit;
    }

    function getDeposits() external view returns (DepositStruct[] memory) {
        return activeDeposits;
    }

    function getDeletedDeposit()
        external
        view
        ownerOnly
        returns (DepositStruct[] memory)
    {
        return inactiveDeposits;
    }

    function deleteDeposit(
        uint256 DepositId,
        address _from
    ) external returns (bool) {
        require(authorOf[DepositId] == _from, "Unauthorized entity");

        for (uint i = 0; i < activeDeposits.length; i++) {
            if (activeDeposits[i].DepositId == DepositId) {
                activeDeposits[i].isActive = false;
                activeDeposits[i].updated = block.timestamp;
                inactiveDeposits.push(activeDeposits[i]);
                delDepositOf[DepositId] = authorOf[DepositId];
                delete activeDeposits[i];
                delete authorOf[DepositId];
            }
        }

        DepositsOf[_from]--;
        inactiveDepositCounter++;
        activeDepositCounter--;

        emit Action(
            DepositId,
            "Deposit DELETED",
            false,
            _from,
            block.timestamp
        );

        return true;
    }
}
