import { environment } from './../../environments/environment';
import { Injectable, Output, EventEmitter } from '@angular/core';
import { Observable } from 'rxjs/Observable';
// import Web3 from 'web3';
// import contract = require('truffle-contract');

declare let require: any;

const Web3 = require('web3');
const contract = require('truffle-contract');
const contractAbi = require('../../../build/contracts/GameManager.json');

declare var window: any;

@Injectable()
export class Web3Service {
  private web3: any;
  private contracts: any = {};
  @Output() accountChanged: EventEmitter<any> = new EventEmitter();
  @Output() initialized: EventEmitter<any> = new EventEmitter();

  constructor() {
  }

  public init(): any {
    this.setProvider();
    this.initialized.emit(this.web3.eth.accounts[0]);
    return this.initContracts();
  }

    public hasMetaMask() : boolean {
        return typeof window.web3 !== 'undefined' && window.web3.currentProvider.isMetaMask;
    }

    public isMetaMaskLocked() : boolean {
        return this.hasMetaMask() && window.web3.eth.accounts.length < 1;
    }

  // Verify if an instance of web3 is already injected (Metamask), if not create a new one.
  private setProvider() {
    if (typeof window.web3 !== 'undefined') {
        this.web3 = new Web3(window.web3.currentProvider);
        this.checkChanges();
    } else {
    //    TODO 
    }
  }

  // Init any contracts, for now we only have to init the main one (GameManager).
  private initContracts() {
    this.contracts.EtherBinary = contract(contractAbi);
    this.contracts.EtherBinary.setProvider(this.web3.currentProvider);
    // this.startEventListerner();
    return this.contracts.EtherBinary;
  }

  public getWeb3Instance() {
    return this.web3;
  }

  public getEther(balance: number) {
    return this.web3.fromWei(balance, 'ether')
  }

  public getWei(amount: number) {
    return this.web3.toWei(amount, 'ether')
  }

  /* Just to test the if the balnce increases
    this addres is updated everytime the contract is deployed
    can be found in ~/build/contracts/EtherBinary.json
  */
  public getContractBalance(address: string): Promise<any> {
    return new Promise<any>((resolve, reject) => {
        this.web3.eth.getBalance(address, (err, res) => {
          if (err) {
            reject(err);
          }else {
            resolve(this.getEther(res));
          }
      });
    });
  }

  private checkChanges() {
    let account = this.web3.eth.accounts[0];
    const that = this;
    const accountInterval = setInterval(function() {
      if (this.web3.eth.accounts[0] !== account) {
        account = this.web3.eth.accounts[0];
        that.accountChanged.emit(account);
      }
    }, 100);
   }
}
