import { Component } from '@angular/core';
import { ConnectFormComponent } from '../connect-form/connect-form.component';
import { NavbarComponent } from "../navbar/navbar.component";

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ConnectFormComponent, NavbarComponent],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
})
export class LoginComponent {

}
