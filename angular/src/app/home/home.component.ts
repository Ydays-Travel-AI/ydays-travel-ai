import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HeroComponent } from '../hero/hero.component';
import { CardsComponent } from '../cards/cards.component';
import { FooterComponent } from '../footer/footer.component';
import { InfoComponent } from '../info/info.component';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, HeroComponent, CardsComponent, FooterComponent, InfoComponent],
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent {}
