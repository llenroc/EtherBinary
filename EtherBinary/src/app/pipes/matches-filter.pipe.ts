import { Pipe, PipeTransform } from '@angular/core';
import { Match } from '../models/Match'

@Pipe({ name: 'matchesFilter', pure: false})
export class MatchesFilter implements PipeTransform {
    transform(items: Match[], filter: any): any {
        if (!items || !filter) {
            return items;
        }

        return items.filter(item => (item.Id == filter.Id));
    }
}