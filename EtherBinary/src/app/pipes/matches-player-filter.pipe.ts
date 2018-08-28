import { Pipe, PipeTransform } from '@angular/core';
import { Match } from '../models/Match'

@Pipe({ name: 'matchesPlayerFilter', pure: false})
export class MatchesPlayerFilter implements PipeTransform {
    transform(items: Match[]): any {
        if (!items) {
            return items;
        }

        return items.filter(item => (item.PlayerTotalTickets > 0));
    }
}