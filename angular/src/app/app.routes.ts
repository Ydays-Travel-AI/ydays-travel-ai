import { Routes } from '@angular/router';
import { LoginComponent } from './login/login.component';
import { HomeComponent } from './home/home.component';
import { TravelDetailComponent } from './travel-detail/travel-detail.component';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'home', component: HomeComponent },
  { path: 'travel-detail', component: TravelDetailComponent},
  { path: '', redirectTo: 'home', pathMatch: 'full' }
];
