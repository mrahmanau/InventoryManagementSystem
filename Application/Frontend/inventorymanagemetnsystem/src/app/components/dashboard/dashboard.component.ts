import { Component } from '@angular/core';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.css',
})
export class DashboardComponent {
  firstName: string | null;
  lastName: string | null;
  role: string | null;
  email: string | null;

  constructor(private authService: AuthService) {
    this.firstName = this.authService.getUserFirstName();
    this.lastName = this.authService.getUserLastName();

    this.role = this.authService.getUserRole();
    this.email = this.authService.getUserEmail();
  }

  getWelcomeMessage(): string {
    return `Welcome back, ${this.firstName}!`;
  }
}
