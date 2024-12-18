import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ConnectFormComponent } from "./connect-form/connect-form.component";

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, ConnectFormComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
})
export class AppComponent {
  title = 'angular';
}
