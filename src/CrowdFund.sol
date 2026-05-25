// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract CrowdFund {
    using PriceConverter for uint256;
    //-------Errors-------
    error NotOwner();
    error DidNotFund();

    //-------Events-------
    event Funded (address indexed funder, uint256 amount);
    event Refunded(address indexed funder, uint256 amount);


    //-------State Variables-------
    uint8 public constant MINIMUM_USD = 5;
    uint256 public constant GOAL = 100e18;
    address private immutable OWNER;
    uint256 public DEADLINE;
    AggregatorV3Interface public PriceFeed;

    //-------Constructor-------
    constructor(address PRICEFEED) {
        OWNER = msg.sender;
        PriceFeed = AggregatorV3Interface(PRICEFEED);
        DEADLINE = block.timestamp + 30 days;
    }

    //-------Storage Variables-------
    mapping(address => uint256) public s_addressToAmountFunded;
    address[] private s_funders;


    //-------Functions-------
    function fund() public payable {
        require(msg.value.getPriceInUSD(PriceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
        emit Funded(msg.sender, msg.value);
    }

    function withdraw() public {
        if(msg.sender != OWNER) {
            revert NotOwner();
        }
        for (uint256 index=0; index < s_funders.length; index++) {
            address funder = s_funders[index];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function Refund() public { 
        require(address(this).balance < GOAL, "Goal has been reached, cannot refund");
        require(block.timestamp > DEADLINE, "Deadline has not been reached, cannot refund");
        if(s_addressToAmountFunded[msg.sender] == 0) {
            revert DidNotFund();
        }
        uint256 amountToRefund = s_addressToAmountFunded[msg.sender];
        s_addressToAmountFunded[msg.sender] = 0;
        (bool callSuccess, ) = payable(msg.sender).call{
            value: amountToRefund
        }("");
        require(callSuccess, "Call failed");
        emit Refunded(msg.sender, amountToRefund);

    }

    function getVersion() public view returns (uint256) {
        return PriceFeed.version();
    }

    function getFundedAmount(address funderAddress) external view returns(uint256) {
        return s_addressToAmountFunded[funderAddress];
    }

    function getFunderAddress(uint256 funderIndex) external view returns (address) {
        return s_funders[funderIndex];
    }

    function getOwner() external view returns (address) {
        return OWNER;
    }


    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

}
