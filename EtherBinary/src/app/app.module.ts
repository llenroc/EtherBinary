import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
import { AngularFontAwesomeModule } from 'angular-font-awesome';
import { ModalModule } from 'ngx-bootstrap';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { MatchesFilter } from './pipes/matches-filter.pipe';
import { MatchesPlayerFilter } from './pipes/matches-player-filter.pipe';
import { OrderModule } from 'ngx-order-pipe';

import { AppComponent } from './app.component';
import { HomeComponent } from './home/home.component';
import { Web3Service } from './services/web3.service';

@NgModule({
  declarations: [
    AppComponent,
    HomeComponent,
    MatchesFilter,
    MatchesPlayerFilter
  ],
  imports: [
    FormsModule,
    BrowserModule,
    HttpModule,
    NgbModule.forRoot(),
    AngularFontAwesomeModule,
    ModalModule.forRoot(),
    OrderModule
  ],
  providers: [Web3Service],
  bootstrap: [AppComponent]
})
export class AppModule { }
