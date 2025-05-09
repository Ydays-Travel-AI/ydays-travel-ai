import { Routes } from '@angular/router';
import path from 'path';
import { LoginComponent } from './login/login.component';
import { app } from '../../server';
import { AppComponent } from './app.component';

export const routes: Routes = [
    {path: 'login', component: LoginComponent},
    {path: 'home', component: AppComponent}
];
