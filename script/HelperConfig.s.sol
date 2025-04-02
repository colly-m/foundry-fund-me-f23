// SPDX-License-Identifier: MIT


// Deploy mocks when we are on local anvil chain
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    NetworkConfig public activeNetworkConfig;

    // uint256 public constant DECIMALS = 8;
    // int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
	if (block.chainid == 300) {
	    activeNetworkConfig = getZksyncSepoliaEthConfig();
	} else {
	    activeNetworkConfig = getOrCreateAnvilEthConfig();
	}
    }

    function getZksyncSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // Price feed Address
	NetworkConfig memory zksyncsepoliaConfig = NetworkConfig({
	    priceFeed: 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF});
	return zksyncsepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
	if (activeNetworkConfig.priceFeed != address(0)) {
	    return activeNetworkConfig;
	}

        // Price Feed Address Mocks

	vm.startBroadcast();
	MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
	vm.stopBroadcast();

	NetworkConfig memory anvilConfig = NetworkConfig({
	    priceFeed: address(mockPriceFeed)
	});
	return anvilConfig;
    }
}
