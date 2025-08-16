
# 💰 FundMe – Decentralized Crowdfunding Smart Contract (Foundry)

A simple and gas-optimized crowdfunding smart contract built in **Solidity (0.8.18)**.  
Users can fund the contract with ETH, and only the **owner** can withdraw. The contract uses **Chainlink Price Feeds** to enforce a minimum funding threshold in **USD**.

---

## 🔍 What This Smart Contract Does

- Accepts ETH from anyone via `fund()`  
- Uses **Chainlink AggregatorV3 Price Feeds** to ensure a minimum contribution of `$5` (in ETH equivalent)
- Tracks how much each address has funded
- Allows only the **owner** to withdraw contributions
- Has both a standard `withdraw()` and a gas-optimized `cheaperWithdraw()`
- Automatically responds to direct ETH transfers via `receive()` & `fallback()`

---

## 🛠️ Tech Stack

| Layer      | Tools / Services                                |
|-----------|--------------------------------------------------|
| Language   | Solidity `^0.8.18`                               |
| Framework  | Foundry (`forge`, `cast`, `anvil`)               |
| Oracle     | Chainlink Price Feeds (`AggregatorV3Interface`)  |
| Network    | Sepolia / Goerli / Mainnet (EVM Compatible)      |

---

## 📦 Getting Started

### 1️⃣ Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2️⃣ Clone Repo & Install Deps

```bash
git clone <repo-url>
cd <project>
forge install
```

### 3️⃣ Create `.env` File

```
PRIVATE_KEY=0xabc123...
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/...
ETHERSCAN_API_KEY=XYZ
PRICE_FEED_ADDRESS=0x694AA1769357215DE4FAC081bf1f309aDC325306   # (example: Sepolia ETH/USD)
```

---

## 🚀 Deploy

```bash
forge script script/DeployFundMe.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast \
  --verify
```

---

## ⚙️ Usage

### ✅ Fund the Contract

```bash
cast send <contract_address> "fund()" \
  --value 0.01ether \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL
```

### 💸 Withdraw (ONLY OWNER)

```bash
cast send <contract_address> "cheaperWithdraw()" \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL
```

---

## 🧠 Key Concepts Demonstrated

| Concept                 | Usage In Contract                          |
|------------------------|--------------------------------------------|
| Libraries              | `PriceConverter` for ETH → USD conversions |
| Modifiers              | `onlyOwner()` access control               |
| Mappings / Arrays      | Track funders and contributions            |
| Chainlink Price Feeds  | Enforce minimum funding in USD             |
| receive() & fallback() | Make contract auto-fundable via ETH send   |

---

## 📄 Contract Summary

| Function             | Description                                                       |
|---------------------|-------------------------------------------------------------------|
| `fund()`            | Accept ETH (≥ $5) and track sender/funded amount                   |
| `withdraw()`        | Withdraw balance – resets funders array (owner only)               |
| `cheaperWithdraw()` | Gas efficient withdraw implementation                              |
| `getAddressToAmountFunded()` | Returns amount funded by an address                   |
| `receive()` / `fallback()`   | Triggered when ETH sent or data does not match any function |


## ✍️ Author

**Ebenezer Igbinoba**  
<https://github.com/eben4real>
````
