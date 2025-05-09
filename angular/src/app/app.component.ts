import { Component } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { LoginComponent } from './login/login.component';
import { ConnectFormComponent } from "./connect-form/connect-form.component";
import { NavbarComponent } from "./navbar/navbar.component";
import { HeroComponent } from "./hero/hero.component";
import { SearchComponent } from "./search/search.component";
import { FooterComponent } from "./footer/footer.component";
import { CardsComponent } from "./cards/cards.component";

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, ConnectFormComponent, LoginComponent, RouterLink, RouterLinkActive, NavbarComponent, HeroComponent, SearchComponent, FooterComponent, CardsComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
})
export class AppComponent {
  title = 'angular';
}
