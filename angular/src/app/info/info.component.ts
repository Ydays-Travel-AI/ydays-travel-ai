import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-info',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './info.component.html',
  styleUrls: ['./info.component.scss']
})
export class InfoComponent {
  blocks = [
    { img: 'assets/img1.jpg' },
    { img: 'assets/img2.jpg' },
    { img: 'assets/img3.jpg' }
  ];
}
