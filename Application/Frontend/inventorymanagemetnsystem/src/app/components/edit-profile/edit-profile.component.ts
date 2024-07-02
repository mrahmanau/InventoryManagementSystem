import { Component, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { UsersService } from '../../services/users.service';
import { AuthService } from '../../services/auth.service';
import { EditProfileDTO } from '../../models/EditProfileDTO';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-edit-profile',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  templateUrl: './edit-profile.component.html',
  styleUrl: './edit-profile.component.css',
})
export class EditProfileComponent implements OnInit {
  editProfileForm: FormGroup;
  successMessage: string | null = null;
  errorMessage: string | null = null;
  userId: number | null = null;
  profilePictureUrl: string | null = null;

  constructor(
    private fb: FormBuilder,
    private userService: UsersService,
    private authService: AuthService
  ) {
    this.editProfileForm = this.fb.group({
      firstName: ['', [Validators.required, Validators.minLength(2)]],
      lastName: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]],
      username: ['', [Validators.required, Validators.minLength(4)]],
    });
  }

  ngOnInit(): void {
    this.userId = this.authService.getUserId();
    if (this.userId) {
      this.userService.getUserById(this.userId).subscribe({
        next: (user) => {
          this.editProfileForm.patchValue({
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            username: user.userName,
          });
          this.profilePictureUrl = user.profileImagePath;
        },
        error: (err) => {
          this.errorMessage =
            'Error fetching user details: ' + err.error.message;
        },
      });
    } else {
      this.errorMessage = 'User ID not found.';
    }
  }

  onSubmit() {
    this.clearMessages();
    if (this.editProfileForm.valid && this.userId !== null) {
      const editProfileDto: EditProfileDTO = {
        userId: this.userId,
        ...this.editProfileForm.value,
      };
      this.userService.updateProfile(editProfileDto).subscribe({
        next: (res) => {
          this.successMessage = 'Profile updated successfully.';
        },
        error: (err) => {
          this.errorMessage = 'Error: ' + err.error.message;
        },
      });
    }
  }

  clearMessages(): void {
    this.successMessage = null;
    this.errorMessage = null;
  }
}
