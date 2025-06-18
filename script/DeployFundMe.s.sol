// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Before broadcst is not a real transaction
        HelperConfig helperConfig = new HelperConfig();
        (address ethAddressPriceFeed) = helperConfig.activeNetworkConfig();

        // After broadcast is a real transaction
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethAddressPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
