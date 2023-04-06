// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IConnext} from "@connext/nxtp-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "hardhat/console.sol";

contract BulkSwap {
    using SafeERC20 for IERC20;

    IConnext public immutable connext;

    // struct Deposit {
    //     address to;
    //     uint256 amount;
    //     uint256 timestamp;
    //     address fromToken;
    //     address toToken;
    //     bool isActive;
    // }

    constructor(IConnext _connext) {
        connext = _connext;
        owner = msg.sender;
    }

    // mapping(address => Deposit) public deposits;

    // function deposit(
    //     address _to,
    //     uint256 _amount,
    //     address _fromToken,
    //     address _toToken
    // ) external {
    //     deposits[msg.sender] = Deposit({
    //         to: _to,
    //         amount: _amount,
    //         timestamp: block.timestamp,
    //         fromToken: _fromToken,
    //         toToken: _toToken,
    //         isActive: true
    //     });
    // }

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
        bool isActive;
        uint256 created;
    }

    DepositStruct[] activeDeposits;
    DepositStruct[] inactiveDeposits;

    event Action(
        uint256 indexed DepositId,
        string actionType,
        Deactivated deleted,
        address indexed executor,
        uint256 createdAt
    );

    modifier ownerOnly() {
        require(msg.sender == owner, "Owner reserved only");
        _;
    }

    function createDeposit(
        address _to,
        uint256 _amount,
        address _fromToken,
        address _toToken
    ) external returns (bool) {
        DepositCounter++;
        authorOf[DepositCounter] = msg.sender;
        DepositsOf[msg.sender]++;
        activeDepositCounter++;

        activeDeposits.push(
            DepositStruct(
                DepositCounter,
                _to,
                _amount,
                _fromToken,
                _toToken,
                msg.sender,
                Deactivated.NO,
                block.timestamp,
                block.timestamp
            )
        );

        emit Action(
            DepositCounter,
            "Deposit CREATED",
            Deactivated.NO,
            msg.sender,
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

    function deleteDeposit(uint256 DepositId) external returns (bool) {
        require(authorOf[DepositId] == msg.sender, "Unauthorized entity");

        for (uint i = 0; i < activeDeposits.length; i++) {
            if (activeDeposits[i].DepositId == DepositId) {
                activeDeposits[i].deleted = Deactivated.YES;
                activeDeposits[i].updated = block.timestamp;
                inactiveDeposits.push(activeDeposits[i]);
                delDepositOf[DepositId] = authorOf[DepositId];
                delete activeDeposits[i];
                delete authorOf[DepositId];
            }
        }

        DepositsOf[msg.sender]--;
        inactiveDepositCounter++;
        activeDepositCounter--;

        emit Action(
            DepositId,
            "Deposit DELETED",
            Deactivated.YES,
            msg.sender,
            block.timestamp
        );

        return true;
    }

    // function restorDeletedDeposit(
    //     uint256 DepositId,
    //     address author
    // ) external ownerOnly returns (bool) {
    //     require(delDepositOf[DepositId] == author, "Unmatched Author");

    //     for (uint i = 0; i < inactiveDeposits.length; i++) {
    //         if (inactiveDeposits[i].DepositId == DepositId) {
    //             inactiveDeposits[i].deleted = Deactivated.NO;
    //             inactiveDeposits[i].updated = block.timestamp;

    //             activeDeposits.push(inactiveDeposits[i]);
    //             delete inactiveDeposits[i];
    //             authorOf[DepositId] = delDepositOf[DepositId];
    //             delete delDepositOf[DepositId];
    //         }
    //     }

    //     DepositsOf[author]++;
    //     inactiveDepositCounter--;
    //     activeDepositCounter++;

    //     emit Action(
    //         DepositId,
    //         "Deposit RESTORED",
    //         Deactivated.NO,
    //         msg.sender,
    //         block.timestamp
    //     );

    //     return true;
    // }
}
