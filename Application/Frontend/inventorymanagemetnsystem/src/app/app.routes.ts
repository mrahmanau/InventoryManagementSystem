import { Routes } from '@angular/router';
import { LoginComponent } from './components/auth/login/login.component';
import { RegisterComponent } from './components/auth/register/register.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { AuthGuard } from './components/auth/authguard/auth.guard';
import { HomeComponent } from './components/home/home.component';
import { AdminComponent } from './components/admin/admin.component';
import { RoleGuard } from './components/auth/roleguard/role-guard';
import { AddProductComponent } from './components/add-product/add-product.component';
import { ProductsListComponent } from './components/products-list/products-list.component';
import { ProductDetailsComponent } from './components/product-details/product-details.component';
import { ProductUpdateComponent } from './components/product-update/product-update.component';
import { EmailConfirmationComponent } from './components/auth/email-confirmation/email-confirmation.component';
import { TwoFactorAuthenticationComponent } from './components/auth/two-factor-authentication/two-factor-authentication.component';
import { PaymentComponent } from './components/payment/payment.component';
import { CartComponent } from './components/cart/cart.component';
import { ContactComponent } from './components/contact/contact.component';
import { EditProfileComponent } from './components/edit-profile/edit-profile.component';

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
  { path: 'confirm-email', component: EmailConfirmationComponent },
  {
    path: '2fa',
    component: TwoFactorAuthenticationComponent,
  },
  { path: 'reset-password', component: LoginComponent },
  { path: 'payment', component: PaymentComponent },
  {
    path: 'dashboard',
    component: DashboardComponent,
    canActivate: [AuthGuard],
  },
  { path: 'edit-profile', component: EditProfileComponent },
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
  {
    path: 'products-list',
    component: ProductsListComponent,
    canActivate: [AuthGuard],
  },
  {
    path: 'product-details/:id',
    component: ProductDetailsComponent,
    canActivate: [AuthGuard],
  },

  {
    path: 'product-update/:id',
    component: ProductUpdateComponent,
    canActivate: [AuthGuard, RoleGuard],
    data: { expectedRole: 'Admin' },
  },
  {
    path: 'cart',
    component: CartComponent,
  },

  {
    path: 'contact',
    component: ContactComponent,
  },
];
