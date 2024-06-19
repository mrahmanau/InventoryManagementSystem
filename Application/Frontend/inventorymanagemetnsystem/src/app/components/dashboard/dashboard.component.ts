import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../services/auth.service';
import { UsersService } from '../../services/users.service';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.css',
})
export class DashboardComponent implements OnInit {
  firstName: string | null;
  lastName: string | null;
  role: string | null;
  email: string | null;
  profileImagePath: string | null;

  constructor(
    private authService: AuthService,
    private userService: UsersService
  ) {
    this.firstName = null;
    this.lastName = null;
    this.role = null;
    this.email = null;
    this.profileImagePath = null;
  }

  ngOnInit(): void {
    const userId = this.authService.getUserId();
    if (userId !== null && userId !== undefined) {
      this.userService.getUserById(userId).subscribe({
        next: (user) => {
          this.firstName = user.firstName;
          this.lastName = user.lastName;
          this.role = user.roleName;
          this.email = user.email;
          this.profileImagePath = user.profileImagePath;
        },
        error: (err) => {
          console.error('Error fetching user data', err);
        },
      });
    } else {
      console.error('User ID is null or undefined.');
    }
  }

  getWelcomeMessage(): string {
    return `Welcome back, ${this.firstName}!`;
  }
}
