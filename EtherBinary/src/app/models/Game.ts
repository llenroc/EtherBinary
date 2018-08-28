import { Match } from "./Match";

export class Game {
    Address: string;
    AssetPair: string;
    AssetPairAlias: string;
    Description: string;
    MaxTicketsPerPlayer: number;
    TicketPrice: number;
    BetsDurationMinutes: number;
    GetResultsMinutes: number;
    CurrentMatchId: number;
    Matches: Match[];
    BuyingTicket: boolean;
    TicketsToBuy: number;
    IsLoaded: boolean;
    ErrorMessage: string;
    PlayerTotalEarnings: number;
    PlayerWithdrawnEarnings: number;
    PlayerPendingEarnings: number;
}