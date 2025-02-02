import { Component } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { LoginComponent } from './login/login.component';
import { ConnectFormComponent } from "./connect-form/connect-form.component";

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, ConnectFormComponent, LoginComponent, RouterLink, RouterLinkActive],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
})
export class AppComponent {
  title = 'angular';
}
