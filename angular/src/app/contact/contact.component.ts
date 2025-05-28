import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-contact',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './contact.component.html',
  styleUrls: ['./contact.component.scss']
})
export class ContactComponent {
  name = '';
  email = '';
  message = '';

  onSubmit() {
    console.log('Form submitted:', {
      name: this.name,
      email: this.email,
      message: this.message
    });
    alert('Votre message a été envoyé. Merci !');
    this.name = '';
    this.email = '';
    this.message = '';
  }
}