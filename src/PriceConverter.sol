//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter { 

    function getPrice(AggregatorV3Interface PriceFeed) internal view returns (uint256) {
        (, int256 price,,,) = PriceFeed.latestRoundData();
        return uint256(price * 1e10);
        
    }

    function getPriceInUSD(uint256 ethAmount, AggregatorV3Interface PriceFeed) internal view returns (uint256) {
             uint256 ethPrice = getPrice(PriceFeed);
             uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
             return ethAmountInUsd;
 }

    function getVersion(AggregatorV3Interface PriceFeed) internal view returns (uint256) {
        return PriceFeed.version();
    }
}
