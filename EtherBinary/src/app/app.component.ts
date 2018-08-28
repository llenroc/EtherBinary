import { Component, HostListener} from '@angular/core';
import { Web3Service } from './services/web3.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
    title = 'app';
    currentAccount: any;
    addressBalance: any;
    isLoadingAccount: boolean = true;

    constructor(private web3Service: Web3Service) {
    }

    @HostListener('window:load')
    windowLoaded() {
        // this.isLoadingAccount = true;
        this.web3Service.initialized.subscribe(value => this.web3Initialized(value));
        this.web3Service.accountChanged.subscribe(account => this.refreshAccount(account));
    }

    private web3Initialized(value: string){
        this.refreshAccount(value);
    }

    private refreshAccount(value: string) {
        this.currentAccount = value;
        this.web3Service.getWeb3Instance().eth.getBalance(value, (error, result)=> {
            if(!error){
                this.addressBalance = this.web3Service.getWeb3Instance().fromWei(result.toNumber(), 'ether');
            }
        });

        this.isLoadingAccount = false;
    }
} 