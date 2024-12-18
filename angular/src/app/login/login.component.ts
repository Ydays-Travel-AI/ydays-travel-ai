import { Component } from '@angular/core';
import { ConnectFormComponent } from '../connect-form/connect-form.component';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ConnectFormComponent],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
})
export class LoginComponent {

}
