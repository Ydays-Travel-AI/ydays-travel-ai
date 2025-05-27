import { Component } from '@angular/core';
import { SearchComponent } from "../search/search.component";
import { NavbarComponent } from "../navbar/navbar.component";
import { MatInputModule } from '@angular/material/input';

@Component({
  selector: 'app-hero',
  standalone: true,
  imports: [SearchComponent, NavbarComponent, MatInputModule],
  templateUrl: './hero.component.html',
  styleUrl: './hero.component.scss'
})
export class HeroComponent {

}
