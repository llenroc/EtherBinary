import { MatchStatus } from "./MatchStatus";

export class Match {
    Id: Number;
    Status: MatchStatus;
    InitialPrice: Number;
    FinalPrice: Number;
    StartTime: number;
    EndTime: number;
    BetPeriodEndTime: number;
    HigherTickets: number;
    LowerTickets: number;
    TotalTickets: number;
    EarningsByTicket: number;
    AcceptingBets: boolean;
    WinnerOption: boolean;
    IsPlayerMatch: boolean;
    PlayerWon: boolean;
    PlayerEarnings: number;
    PlayerTotalTickets: number;
    PlayerOption: boolean;
    EarningsWithdrawn: boolean;
}