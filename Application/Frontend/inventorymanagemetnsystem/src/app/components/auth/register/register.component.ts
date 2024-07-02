import { Component } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { AuthService } from '../../../services/auth.service';
import { CommonModule } from '@angular/common';
import { HttpClientModule } from '@angular/common/http';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, HttpClientModule, RouterModule],
  templateUrl: './register.component.html',
  styleUrl: './register.component.css',
})
export class RegisterComponent {
  registerForm: FormGroup;
  successMessage: string | null = null;
  errorMessage: string | null = null;
  profileImage: File | null = null;
  isLoading: boolean = false;

  constructor(private fb: FormBuilder, private authService: AuthService) {
    this.registerForm = this.fb.group({
      firstName: ['', [Validators.required, Validators.minLength(2)]],
      lastName: ['', [Validators.required, Validators.minLength(3)]],
      username: ['', [Validators.required, Validators.minLength(4)]],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]],
      roleId: ['2', [Validators.required]],
    });
  }

  onFileChange(event: any) {
    if (event.target.files && event.target.files.length > 0) {
      this.profileImage = event.target.files[0];
    }
  }

  onSubmit() {
    this.clearMessages();
    if (this.registerForm.valid) {
      this.isLoading = true;
      if (this.profileImage) {
        this.authService.uploadProfileImage(this.profileImage).subscribe({
          next: (response) => {
            const imagePath = response.filePath;
            const user = {
              ...this.registerForm.value,
              profileImagePath: imagePath,
            };
            this.registerUser(user);
          },
          error: (err) => {
            this.errorMessage = 'Error uploading image: ' + err.error.message;
            this.isLoading = false;
          },
        });
      } else {
        this.registerUser(this.registerForm.value);
      }
    }
  }

  registerUser(user: any) {
    this.authService.register(user).subscribe({
      next: (res) => {
        this.successMessage = res.Message;
        this.registerForm.reset();
        this.isLoading = false;
      },
      error: (err) => {
        this.errorMessage = 'Error: ' + err.error.message;
        this.isLoading = false;
      },
    });
  }

  clearMessages(): void {
    this.successMessage = null;
    this.errorMessage = null;
  }
}
