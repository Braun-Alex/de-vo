import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
    solidity: "0.8.18",
    mocha: {
        parallel: true,
        grep: "Deployment",
        invert: true
    }
};

export default config;