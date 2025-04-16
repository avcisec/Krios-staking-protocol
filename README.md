<h1 align="center" id="title">Krios Staking</h1>

<p align="center"><img src="https://socialify.git.ci/avcisec/Krios-staking-protocol/image?custom_description=Krios+is+a+staking+protocol+that+uses+synthetix+staking+mechanism+to+calculate+the+reward+for+users.&description=1&forks=1&issues=1&language=1&owner=1&pattern=Formal+Invitation&pulls=1&stargazers=1" alt="Krios-staking-protocol" width="640" height="320" /></p>


<p align="center"><img src="https://img.shields.io/badge/language-solidity-blue" alt="shields"><img src="https://img.shields.io/badge/getting_started-guide-green" alt="shields"><img src="https://img.shields.io/badge/free_for_non_commercial_use-brightgreen" alt="shields"><img src="https://img.shields.io/badge/Openzeppelin-blue" alt="shields"></p>

⭐ Star me on GitHub — This is my first big project! That motivates me a lot!

[![Share](https://img.shields.io/badge/share-000000?logo=x&logoColor=white)](https://x.com/intent/tweet?text=Check%20out%20this%20project%20on%20GitHub:%20https://github.com/avcisec/Krios-staking-protocol%20%23Krios%20%23Staking%20%23Protocol)
[![Share](https://img.shields.io/badge/share-1877F2?logo=facebook&logoColor=white)](https://www.facebook.com/sharer/sharer.php?u=https://github.com/avcisec/Krios-staking-protocol)
[![Share](https://img.shields.io/badge/share-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/sharing/share-offsite/?url=https://github.com/avcisec/Krios-staking-protocol)
[![Share](https://img.shields.io/badge/share-FF4500?logo=reddit&logoColor=white)](https://www.reddit.com/submit?title=Check%20out%20this%20project%20on%20GitHub:%20https://github.com/avcisec/Krios-staking-protocol)
[![Share](https://img.shields.io/badge/share-0088CC?logo=telegram&logoColor=white)](https://t.me/share/url?url=https://github.com/Abblix/Oidc.Server&text=Check%20out%20this%20project%20on%20GitHub)



## ❓What is Krios?
Krios is an implementation of synthetix staking algorithm. 

## 🚩Features

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

## ⏩Quick Start

```
git clone https://github.com/avcisec/Krios-staking-protocol.git
cd Krios-staking-protocol
forge build
```
# Usage

## Start a local node

```
make anvil
```

## Deploy

This will default to your local node. You need to have it running in another terminal in order for it to deploy.

```
make deploy
```

# Deployment to a testnet or mainnet

1. Setup environment variables

You'll want to set your `SEPOLIA_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

- `PRIVATE_KEY`: The private key of your account (like from [metamask](https://metamask.io/)). **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
  - You can [learn how to export it here](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).
- `SEPOLIA_RPC_URL`: This is url of the sepolia testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)

Optionally, add your `ETHERSCAN_API_KEY` if you want to verify your contract on [Etherscan](https://etherscan.io/).

1. Get testnet ETH

Head over to [faucets.link](https://cloud.google.com/application/web3/faucet/ethereum/sepolia) and get some testnet ETH. You should see the ETH show up in your metamask.

1. Deploy

```
make deploy ARGS="--network sepolia"
```



## 🛡️Contributing & License

Krios is an open-source software licensed under the MIT.

# Thank you!

