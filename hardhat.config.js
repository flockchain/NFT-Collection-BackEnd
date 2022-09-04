require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });

const ALCHEMY_API_KEY_URL = "https://eth-goerli.g.alchemy.com/v2/dBt0kcp0_y8YUA8gmbYJnGK6PAj1lI26";

const GOERLI_PRIVATE_KEY = "186e35dc5ef57926a0a9092534a8ad55011bacb74e12d7cda8378980ee26b5e9";

module.exports = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: ALCHEMY_API_KEY_URL,
      accounts: [GOERLI_PRIVATE_KEY],
    },
  },
};