# EtherBinary <img src="https://github.com/morpheums/EtherBinary/blob/master/EtherBinary/src/assets/images/EtherBinary.png?raw=true" alt="alt text" width="50px">

### Crypto assets binary options powered by smart contracts!
[![GitHub last commit](https://img.shields.io/github/last-commit/morpheums/EtherBinary.svg?style=plastic)]()

## Features
- **Very easy** and intuitive game.
- Uses **[Kraken API](https://www.kraken.com/help/api)** to retrive assets value.
- **Completely managed**  by smart contracts so theres no manipulation.


## Requirements:
1. Install [Node & NPM](https://nodejs.org/en/)
2. Install Angular CLI `npm install -g @angular/cli`
3. Install Truffle `npm install -g truffle`
4. Install [Ganache GUI](https://github.com/trufflesuite/ganache/releases)
5. Install [Install Metamask Extension for Chrome](https://metamask.io/)

## Installation steps:

1. Clone the repository.

```code
    git clone https://github.com/morpheums/EtherBinary.git
```
2. Navigate to the source code location.
```code 
    cd EtherBinary
```
3. Open Ganache GUI and make sure is running @ `http://127.0.0.1:8545`
4. Open a new terminal and run `npm install` to install all dependencies.
5. On a terminal run `npm run bridge` to deploy the oraclize service to your local network .
6. That will generate an Oraclize Address Resolver(OAR), open the file 'contracts/implementations/BaseGame.sol' and copy the generated address into the following function:

```js
    function setAssetPairInformation()
        ...

        // WARNING: Just for development purposes, must be removed when deploying to production/testnet.
        // Setting development oraclize resolver.
        OAR = OraclizeAddrResolverI(EnterYourOarCustomAddress);
       ...
    }
```

7. Open a new terminal and run `truffle migrate --network development` to deploy smart contracts to your local network.
8. Open a new terminal and run `ng serve` to start the development server.
9. Open Chrome web browser and navigate to `http://localhost:4200/`
10. Open the Metamask extension and connect to `http://127.0.0.1:8545` to load local accounts.
11. **Now you are ready to use the EtherBinary DAPP!**

## Testnet:

You can also interact with the Smart Contract already deployed to **Rinkeby** test network @:
```code
    0xd7cf14b3526042c09d09b5750350f02832631b76
```
