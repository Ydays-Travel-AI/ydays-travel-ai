import { Component } from '@angular/core';
import { NavbarComponent } from '../navbar/navbar.component';
import { FooterComponent } from '../footer/footer.component';
import { ActivatedRoute } from '@angular/router';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'app-travel-detail',
  standalone: true,
  imports: [NavbarComponent, FooterComponent, MatInputModule, MatButtonModule],
  templateUrl: './travel-detail.component.html',
  styleUrl: './travel-detail.component.scss'
})
export class TravelDetailComponent {
  voyageId: string | null = null;

  constructor(private route: ActivatedRoute) {
    this.voyageId = this.route.snapshot.paramMap.get('id');
    // Utilise voyageId pour charger les infos du voyage
  }
}
