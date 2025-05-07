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
<<<<<<< HEAD
  imports: [RouterOutlet, ConnectFormComponent, LoginComponent, RouterLink, RouterLinkActive, NavbarComponent, HeroComponent, SearchComponent, FooterComponent, CardsComponent],
=======
  imports: [RouterOutlet, ConnectFormComponent, LoginComponent, RouterLink, RouterLinkActive],
>>>>>>> 40b78d732d5fe51095869a25ed888ac2c694a78f
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
})
export class AppComponent {
  title = 'angular';
}
