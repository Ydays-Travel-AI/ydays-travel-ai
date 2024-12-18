import { Component } from '@angular/core';
import { FormGroup } from '@angular/forms';
import { FormControl } from '@angular/forms';
import { ReactiveFormsModule } from '@angular/forms';

@Component({
  selector: 'app-connect-form',
  standalone: true,
  imports: [ReactiveFormsModule],
  templateUrl: './connect-form.component.html',
  styleUrl: './connect-form.component.scss'
})

export class ConnectFormComponent {
  connectForm = new FormGroup({
    Login: new FormControl(""),
    Password: new FormControl("")
  })

}
