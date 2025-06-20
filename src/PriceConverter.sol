// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// Why is this a library and not abstract?
// Why not an interface?
library PriceConverter {
    // We could make this public, but then we'd have to deploy it
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // Sepolia ETH / USD Address
        // https://docs.chain.link/data-feeds/price-feeds/addresses
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306
        // );
        // This returns the latest price of ETH in USD, plus metadata.
        (, int256 answer,,,) = priceFeed.latestRoundData(); // chainlink returns the answer in 8 decimal place (i.e) answer * 10^8
        // ETH/USD rate in 18 digit
        return uint256(answer * 10000000000); // To convert the answer from chain link into an 18 digits value multiply by 10^10 to make it sum up to 10^18.
    }

    // 1000000000
    /**
     * Let’s say someone sends 0.0025 ETH:
     * In Solidity, that’s: ethAmount = 0.0025 * 10^18 = 2.5e15 wei
     */
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed); // ethPrice = 2_000 * 10^18 = 2e21
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        // the actual ETH/USD conversion rate, after adjusting the extra 0s.
        return ethAmountInUsd;
    }
}
