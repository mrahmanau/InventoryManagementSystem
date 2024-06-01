import { Routes } from '@angular/router';
import { LoginComponent } from './components/auth/login/login.component';
import { RegisterComponent } from './components/auth/register/register.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { AuthGuard } from './components/auth/authguard/auth.guard';
import { HomeComponent } from './components/home/home.component';
import { AdminComponent } from './components/admin/admin.component';
import { RoleGuard } from './components/auth/roleguard/role-guard';
import { AddProductComponent } from './components/add-product/add-product.component';

export const routes: Routes = [
  {
    path: '',
    component: HomeComponent,
  },
  {
    path: 'register',
    component: RegisterComponent,
  },
  {
    path: 'login',
    component: LoginComponent,
  },
  {
    path: 'dashboard',
    component: DashboardComponent,
    canActivate: [AuthGuard],
  },
  {
    path: 'admin',
    component: AdminComponent,
    canActivate: [AuthGuard, RoleGuard],
    data: { expectedRole: 'Admin' },
  },
  {
    path: 'add-product',
    component: AddProductComponent,
    canActivate: [AuthGuard, RoleGuard],
    data: { expectedRole: 'Admin' },
  },
];
