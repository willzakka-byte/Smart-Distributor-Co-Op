# 🌐 Smart Distributor Co-Op

A decentralized autonomous organization (DAO) smart contract that enables distributors across different regions to form a cooperative and dynamically split profits based on verified sales volume.

## 📋 Overview

The Smart Distributor Co-Op contract allows distributors to:
- 🤝 Join a regional co-operative network
- 📊 Report sales volumes in real-time
- 💰 Earn proportional profits based on sales performance
- 🏛️ Participate in a transparent, blockchain-based profit distribution system

## ✨ Key Features

- **Regional Distribution Network**: Distributors join with their regional identifier
- **Dynamic Profit Splitting**: Profits distributed proportionally based on verified sales
- **Treasury Management**: Secure treasury pool for profit distribution
- **Period-Based Accounting**: Sales tracked in discrete periods for fair distribution
- **Governance Controls**: Owner-controlled member management and threshold settings

## 🚀 Getting Started

### Prerequisites

- Clarinet CLI installed
- Stacks wallet for testing

### Installation

```bash
clarinet integrate
```

## 📖 Usage

### For Distributors

#### 1. Join the Co-Op 🎯

```clarity
(contract-call? .Smart-Distributor-Co-Op join-coop "North-America")
```

#### 2. Report Sales 📈

```clarity
(contract-call? .Smart-Distributor-Co-Op report-sales u5000)
```

#### 3. Claim Your Earnings 💵

```clarity
(contract-call? .Smart-Distributor-Co-Op claim-earnings)
```

### For Contributors

#### Add Funds to Treasury 💳

```clarity
(contract-call? .Smart-Distributor-Co-Op contribute-to-treasury u10000)
```

### For Contract Owner

#### Distribute Profits 🎁

```clarity
(contract-call? .Smart-Distributor-Co-Op distribute-profits)
```

#### Advance Period ⏭️

```clarity
(contract-call? .Smart-Distributor-Co-Op advance-period)
```

#### Update Minimum Sales Threshold 📏

```clarity
(contract-call? .Smart-Distributor-Co-Op update-min-threshold u2000)
```

#### Manage Members 👥

```clarity
(contract-call? .Smart-Distributor-Co-Op deactivate-member 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
(contract-call? .Smart-Distributor-Co-Op reactivate-member 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## 🔍 Read-Only Functions

### Check Member Status

```clarity
(contract-call? .Smart-Distributor-Co-Op get-member 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
(contract-call? .Smart-Distributor-Co-Op is-member 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### View Earnings

```clarity
(contract-call? .Smart-Distributor-Co-Op get-member-earnings 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Check Treasury Balance

```clarity
(contract-call? .Smart-Distributor-Co-Op get-treasury-balance)
```

### View Regional Stats

```clarity
(contract-call? .Smart-Distributor-Co-Op get-regional-stats "North-America")
```

### Get Period Information

```clarity
(contract-call? .Smart-Distributor-Co-Op get-current-period)
(contract-call? .Smart-Distributor-Co-Op get-period-info u0)
(contract-call? .Smart-Distributor-Co-Op get-period-sales u0 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## 🏗️ Contract Architecture

### Data Structures

- **Members Map**: Stores distributor information (region, sales, status)
- **Period Sales Map**: Tracks sales per member per period
- **Period Totals Map**: Aggregates total sales and distribution status
- **Member Earnings Map**: Cumulative earnings per distributor
- **Regional Stats Map**: Statistics grouped by region

### Core Workflow

1. **Joining**: Distributors join with regional identifier
2. **Reporting**: Members report sales throughout the period
3. **Distribution**: Owner triggers profit distribution when threshold met
4. **Claiming**: Members claim their proportional share
5. **New Period**: Cycle repeats with advanced period

## 🔒 Security Features

- Owner-only administrative functions
- Active member validation
- Minimum sales threshold enforcement
- Duplicate distribution prevention
- Balance verification before transfers

## 🧪 Testing

```bash
clarinet test
```

## 📊 Error Codes

| Code | Description |
|------|-------------|
| u100 | Owner only operation |
| u101 | Not a member |
| u102 | Already a member |
| u103 | Insufficient balance |
| u104 | Invalid amount |
| u105 | No sales recorded |
| u106 | Already distributed |
| u107 | Invalid region |
| u108 | Unauthorized |

## 🤝 Contributing

Contributions welcome! Please ensure:
- Code follows Clarity best practices
- All tests pass
- Documentation is updated

## 📄 License

MIT License

## 🛠️ Built With

- Clarity Smart Contracts
- Stacks Blockchain
- Clarinet Development Tool

---

**Made with ❤️ for decentralized distribution networks**
