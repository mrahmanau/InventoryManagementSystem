import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../services/auth.service';
import { UsersService } from '../../services/users.service';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { EditPasswordDTO } from '../../models/EditPasswordDTO';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.css',
})
export class DashboardComponent implements OnInit {
  firstName: string | null;
  lastName: string | null;
  role: string | null;
  email: string | null;
  profileImagePath: string | null;

  editPasswordForm: FormGroup;
  showPasswordForm: boolean = false;
  successMessage: string | null = null;
  errorMessage: string | null = null;

  constructor(
    private authService: AuthService,
    private userService: UsersService,
    private fb: FormBuilder
  ) {
    this.firstName = null;
    this.lastName = null;
    this.role = null;
    this.email = null;
    this.profileImagePath = null;

    this.editPasswordForm = this.fb.group({
      currentPassword: ['', Validators.required],
      newPassword: [
        '',
        [
          Validators.required,
          Validators.minLength(8),
          Validators.pattern(
            /(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*])/
          ),
        ],
      ],
    });
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

  togglePasswordForm() {
    this.showPasswordForm = !this.showPasswordForm;
    this.clearMessages();
    this.editPasswordForm.reset();
  }

  onSubmitPassword() {
    this.clearMessages();
    const userId = this.authService.getUserId();
    if (this.editPasswordForm.valid && userId !== null) {
      const editPasswordDto: EditPasswordDTO = {
        userId: userId,
        ...this.editPasswordForm.value,
      };
      this.userService.updatePassword(editPasswordDto).subscribe({
        next: () => {
          this.successMessage = 'Password updated successfully.';
          //this.togglePasswordForm();
        },
        error: (err) => {
          if (err.error.errors) {
            this.errorMessage = err.error.errors.join('. ');
          } else {
            this.errorMessage = 'Error: ' + err.error.message;
          }
        },
      });
    }
  }

  clearMessages(): void {
    this.successMessage = null;
    this.errorMessage = null;
  }

  getWelcomeMessage(): string {
    return `Welcome back, ${this.firstName}!`;
  }
}
