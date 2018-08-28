import { Web3Service } from './../services/web3.service';
import { Component, OnInit, HostListener, NgZone, ViewChild } from '@angular/core';
import { ModalDirective } from 'ngx-bootstrap';
import { Game } from '../models/Game';
import { Match } from '../models/Match';
import { MatchStatus } from '../models/MatchStatus';
import * as moment from 'moment';

declare let require: any;
declare var window: any;

const baseGameAbi = require('../../../build/contracts/BaseGame.json');

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent {
  @ViewChild('lgModal') public lgModal: ModalDirective;
  
    gameContract : any;
    currentAccount: any;
    isLoadingAccount: boolean = true;
    currentGamesList: Game[] = [];
    buyingTicket: boolean = false;
    withdrawingEarnings: boolean = false;
    buyTicketGas = 500000;
    
    modalGame: Game = new Game();
    modals: any = { currentModal: '', myHistory: 'myHistory' , historic: 'historic'}

    constructor(private web3Service: Web3Service, private _ngZone: NgZone) {
    }

    @HostListener('window:load')
    windowLoaded() {
        this.init();
        this.web3Service.accountChanged.subscribe(account => window.location.reload());
    }

    init() {
        if(this.hasMetaMask() && !this.isMetaMaskLocked()) {
            this.gameContract = this.web3Service.init();
            this.setCurrentAccount();
        }
    }

    private setCurrentAccount(){
        this.web3Service.getWeb3Instance().eth.getAccounts((err, acc) => {
            if (!err) {
                this.currentAccount = acc[0];
                this.isLoadingAccount = false;
                this._ngZone.run(() => {
                    this.getCurrentGames();
                });
            }
        })
    }

    public hasMetaMask() : boolean{
        return this.web3Service.hasMetaMask();
    }

    public isMetaMaskLocked() : boolean{
        return this.web3Service.isMetaMaskLocked();
    }
    
    public toggleModal(modal, game) {
        if (modal) {
            this.modalGame = game;
            this.lgModal.show();
        } else {
            this.lgModal.hide();
        }
        if (modal) {
            this.modals.currentModal = modal;
        }
    }

    private getCurrentGames(){
        this.gameContract.deployed().then(instance => {
            instance.getDeployedAssetsCount().then(result => {
                for (let index = 0; index < result; index++) {
                    let newGame = new Game();

                    instance.getDeployedAssetContractAt(index).then(assetContract =>{
                        newGame.AssetPair = assetContract[0];
                        newGame.Address = assetContract[1];

                        var contractAbi = this.web3Service.getWeb3Instance().eth.contract(baseGameAbi.abi);
                        var contract =  contractAbi.at(newGame.Address);

                        contract.getGameInfo((error, gameInfo) => {
                            if(error){
                                console.log('An error has occurred: ' + error);
                            }
                            else{
                                // Setting game info.
                                newGame.AssetPairAlias = gameInfo[1];
                                newGame.Description = gameInfo[2];
                                newGame.TicketPrice = this.web3Service.getWeb3Instance().fromWei(gameInfo[3].toNumber(), "ether" );
                                newGame.CurrentMatchId = gameInfo[4].toNumber();
                                newGame.MaxTicketsPerPlayer = gameInfo[5].toNumber();
                                newGame.BetsDurationMinutes = gameInfo[6].toNumber(); 
                                newGame.GetResultsMinutes = gameInfo[7].toNumber();
                                newGame.PlayerTotalEarnings = 0;
                                newGame.PlayerPendingEarnings = 0;
                                newGame.PlayerWithdrawnEarnings = 0;
                                newGame.TicketsToBuy = 0;
                                newGame.Matches = [];
                                newGame.IsLoaded = false;

                                // Loading all matches info.
                                this.setMatchStartedWatcher(contract);
                                this.setTicketBoughtWatcher(contract);
                                this.setBettingPeriodEndWatcher(contract);
                                this.setMatchFinishedWatcher(contract);
                                this.setEarningsWithdrawndWatcher(contract);
                                                    
                                //  Inserting game to array.
                                this.currentGamesList.push(newGame);
                            }
                        });
                    });
                }
            });
        });
    }

    private setMatchStartedWatcher(contract: any) {
        contract.LogMatchStarted({}, { fromBlock: 0, toBlock: 'latest' }).watch((error, result) => {
            if (error){
                console.log('An error has occurred: ' + error);
            }
            else {
                // Looking for game.
                let assetPair = result.args.assetPair;
                let gameIndex = this.currentGamesList.findIndex(item => item.AssetPair == assetPair);
                
                // Looking for match.
                let matchId = result.args.matchId.toNumber();
                let matchIndex = this.currentGamesList[gameIndex].Matches.findIndex(item => item.Id === matchId);
                let matchExists = matchIndex >= 0;

                // Setting match info.
                let match = matchExists ? this.currentGamesList[gameIndex].Matches[matchIndex] : new Match();

                match.Id = matchId;
                match.InitialPrice = (result.args.initialPrice.toNumber() / 100000);
                match.StartTime = result.args.startTime.toNumber();
                match.PlayerTotalTickets =  matchExists ? match.PlayerTotalTickets : 0;
                match.AcceptingBets = matchExists ? match.AcceptingBets : true;
                match.Status = matchExists ? match.Status : MatchStatus.Started; // If match exists don't modify current status.
                match.HigherTickets =  matchExists ? match.HigherTickets : 0;
                match.LowerTickets =  matchExists ? match.LowerTickets : 0;

                //TODO: remove
                console.log(match);

                // If match exists then save new info, if not then add new match to the array.
                if (matchExists) {
                    this.currentGamesList[gameIndex].Matches[matchIndex] = match;
                }
                else {
                    this.currentGamesList[gameIndex].Matches.push(match);
                }
                
                if(this.currentGamesList[gameIndex].CurrentMatchId == matchId) {
                    this.currentGamesList[gameIndex].IsLoaded = true;
                }
            }
        });
    }

    private setTicketBoughtWatcher(contract: any){
        contract.LogTicketBought({}, { fromBlock: 0, toBlock: 'latest' }).watch((error, result) => {
            if (error){ 
                console.log('An error has occurred: ' + error);
            }
            else {
                // Looking for game.
                let assetPair = result.args.assetPair;
                let gameIndex = this.currentGamesList.findIndex(item => item.AssetPair == assetPair);
                
                // Looking for match.
                let matchId = result.args.matchId.toNumber();
                let matchIndex = this.currentGamesList[gameIndex].Matches.findIndex(item => item.Id === matchId);
                let matchExists = matchIndex >= 0;
                
                // Setting match info.
                let match = matchExists? this.currentGamesList[gameIndex].Matches[matchIndex] : new Match();

                match.Id = matchId;
                match.AcceptingBets = matchExists ? match.AcceptingBets : true;
                match.Status = matchExists ? match.Status : MatchStatus.Started; // If match exists don't modify current status.

                if(result.args.player === this.currentAccount) {
                    match.IsPlayerMatch = true;
                    match.PlayerOption = result.args.option;
                    match.PlayerTotalTickets = result.args.playerTotalTickets.toNumber();
                }

                if(result.args.option){
                    match.HigherTickets = result.args.optionTotalTickets.toNumber();
                }
                else{
                    match.LowerTickets = result.args.optionTotalTickets.toNumber();
                }

                match.TotalTickets = match.HigherTickets + match.LowerTickets;

                //TODO: remove
                console.log(match);

                // If match exists then save new info, if not then add new match to the array.
                if (matchExists) {
                    this.currentGamesList[gameIndex].Matches[matchIndex] = match;
                }
                else {
                    this.currentGamesList[gameIndex].Matches.push(match);
                }
            }
        });
    }
   
    private setBettingPeriodEndWatcher(contract: any){
        contract.LogBettingPeriodEnd({}, { fromBlock: 0, toBlock: 'latest' }).watch((error, result) => {
            if (error){
                console.log('An error has occurred: ' + error);
            }
            else{
                // Looking for game.
                let assetPair = result.args.assetPair;
                let gameIndex = this.currentGamesList.findIndex(item => item.AssetPair == assetPair);
                
                // Looking for match.
                let matchId = result.args.matchId.toNumber();
                let matchIndex = this.currentGamesList[gameIndex].Matches.findIndex(item => item.Id === matchId);
                let matchExists = matchIndex >= 0;
                
                // Setting match info.
                let match = matchExists ? this.currentGamesList[gameIndex].Matches[matchIndex] : new Match();

                match.Id = matchId;
                match.Status =  matchExists ? 
                                (match.Status == MatchStatus.Started ? MatchStatus.BettingPeriodFinished : match.Status) : 
                                MatchStatus.BettingPeriodFinished; // If match exists don't modify current status.

                match.BetPeriodEndTime = result.args.timestamp.toNumber();
                match.AcceptingBets = false;

                //TODO: remove
                console.log(match);

                // If match exists then save new info, if not then add new match to the array.
                if (matchExists) {
                    this.currentGamesList[gameIndex].Matches[matchIndex] = match;
                }
                else {
                    this.currentGamesList[gameIndex].Matches.push(match);
                }
            }
        }); 
    }

    private setMatchFinishedWatcher(contract: any) {
        contract.LogMatchFinished({}, { fromBlock: 0, toBlock: 'latest' }).watch((error, result) => {
            if (error){
                console.log('An error has occurred: ' + error);
            }
            else{
                // Looking for game.
                let assetPair = result.args.assetPair;
                let gameIndex = this.currentGamesList.findIndex(item => item.AssetPair == assetPair);
                
                // Looking for match.
                let matchId = result.args.matchId.toNumber();
                let matchIndex = this.currentGamesList[gameIndex].Matches.findIndex(item => item.Id === matchId);
                let matchExists = matchIndex >= 0;
                
                // Setting match info.
                let match = matchExists? this.currentGamesList[gameIndex].Matches[matchIndex] : new Match();

                match.Id = matchId;
                match.AcceptingBets = false;
                match.Status = MatchStatus.Finished;
                match.StartTime = result.args.startTime.toNumber();
                match.EndTime = result.args.endTime.toNumber();
                match.InitialPrice = (result.args.initialPrice.toNumber()  / 100000);
                match.FinalPrice = (result.args.endPrice.toNumber()  / 100000);
                match.EarningsByTicket = this.web3Service.getWeb3Instance().fromWei(result.args.earningsByTicket.toNumber(), "ether" );
                match.WinnerOption = result.args.winnerOption;
                
                // If is a match where the current address is playing then add totals.
                if (match.IsPlayerMatch) {
                    match.PlayerWon =  (match.PlayerOption == match.WinnerOption);

                    if (match.PlayerWon) {
                        match.PlayerEarnings = (match.EarningsByTicket * match.PlayerTotalTickets);
                        this.currentGamesList[gameIndex].PlayerTotalEarnings += match.PlayerEarnings;
                        this.currentGamesList[gameIndex].PlayerPendingEarnings += match.PlayerEarnings;
                    }
                }

                //TODO: remove
                console.log(this.currentGamesList[gameIndex]);
                console.log(match);

                // If match exists then save new info, if not then add new match to the array.
                if (matchExists) {
                    this.currentGamesList[gameIndex].Matches[matchIndex] = match;
                }
                else {
                    this.currentGamesList[gameIndex].Matches.push(match);
                }

                this.currentGamesList[gameIndex].CurrentMatchId = Number(match.Id) + Number(1);
            }
        });
    }

    private setEarningsWithdrawndWatcher(contract: any) {
        contract.LogEarningsWithdrawn({player: this.currentAccount}, { fromBlock: 0, toBlock: 'latest' }).watch((error, result) => {
            if (error){
                console.log('An error has occurred: ' + error);
            }
            else {
                // Looking for game.
                let assetPair = result.args.assetPair;
                let gameIndex = this.currentGamesList.findIndex(item => item.AssetPair == assetPair);
                
                // Looking for match.
                let matchId = result.args.matchId.toNumber();
                let matchIndex = this.currentGamesList[gameIndex].Matches.findIndex(item => item.Id === matchId);
                let matchExists = matchIndex >= 0;
                
                // Setting match info.
                let match = matchExists? this.currentGamesList[gameIndex].Matches[matchIndex] : new Match();
                
                match.Id = matchId;
                match.AcceptingBets = false;
                match.Status = MatchStatus.Finished;
                match.EarningsWithdrawn = true;

                this.currentGamesList[gameIndex].PlayerWithdrawnEarnings += this.web3Service.getWeb3Instance().fromWei(result.args.amount.toNumber(), "ether" );
                this.currentGamesList[gameIndex].PlayerPendingEarnings = 
                    this.currentGamesList[gameIndex].PlayerTotalEarnings - 
                    (this.currentGamesList[gameIndex].PlayerWithdrawnEarnings - (this.currentGamesList[gameIndex].TicketPrice * match.PlayerTotalTickets));

                // If match exists then save new info, if not then add new match to the array.
                if (matchExists) {
                    this.currentGamesList[gameIndex].Matches[matchIndex] = match;
                }
                else {
                    this.currentGamesList[gameIndex].Matches.push(match);
                }
            }
        });
    }
    
    public isLoadingMatches(game) : boolean {
        return (game.Matches.filter(item => item.Id == game.CurrentMatchId) < 1);
    }

    public buyTicket(game: Game) {
        var contractAbi = this.web3Service.getWeb3Instance().eth.contract(baseGameAbi.abi);
        var contract =  contractAbi.at(game.Address);
        var match = game.Matches.filter(item=> item.Id == game.CurrentMatchId)[0];

        game.BuyingTicket = true;
        
        contract.buyTickets(match.PlayerOption, {
            from: this.currentAccount,
            value: this.web3Service.getWei(game.TicketsToBuy * game.TicketPrice),
            gas: this.buyTicketGas
        }, (error, result) =>{
            if(error){
                game.ErrorMessage = error.message;
            }
            else{
                var matchIndex = game.Matches.findIndex(item => item.Id === game.CurrentMatchId);
                game.Matches[matchIndex].PlayerTotalTickets += game.TicketsToBuy;
                game.TicketsToBuy = 0;
            }
            
            game.BuyingTicket = false;
        });
    }

    public withdrawEarnings(game: Game) {
        var contractAbi = this.web3Service.getWeb3Instance().eth.contract(baseGameAbi.abi);
        var contract =  contractAbi.at(game.Address);

        this.withdrawingEarnings = true;

        contract.withdrawEarnings.sendTransaction({from: this.currentAccount, gas: 4712388},
            (error, result) => {
                this.withdrawingEarnings = false;
                if(error){
                    console.log(error);
                }
            }
        );
    }
}