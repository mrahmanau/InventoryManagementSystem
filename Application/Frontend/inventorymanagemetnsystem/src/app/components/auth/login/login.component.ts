import { Component } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { AuthService } from '../../../services/auth.service';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { LoginOutputDTO } from '../../../models/LoginOutputDTO';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css',
})
export class LoginComponent {
  loginForm: FormGroup;
  successMessage: string | null = null;
  errorMessage: string | null = null;
  requiresTwoFactor: boolean = false;
  userId: number | null = null;

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private router: Router
  ) {
    this.loginForm = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required],
    });
  }

  onSubmit() {
    if (this.loginForm.invalid) {
      this.markAllAsTouched();
      return;
    }
    // if (this.loginForm.valid) {
    //   this.authService.login(this.loginForm.value).subscribe({
    //     next: (res) => {
    //       //localStorage.setItem('token', res.token);
    //       this.authService.storeToken(res.token); // Use AuthService to store the token
    //       this.router.navigate(['/dashboard']);
    //     },
    //     error: (err) => {
    //       this.errorMessage = 'Error: ' + err.error.message;
    //       this.successMessage = null;
    //     },
    //   });
    // }
    if (this.loginForm.valid) {
      this.authService.login(this.loginForm.value).subscribe({
        next: (res: LoginOutputDTO) => {
          console.log('Login response:', res); // Log the entire response to the console
          console.log('requiresTwoFactor:', res.requiresTwoFactor); // Log requiresTwoFactor separately
          console.log('userId:', res.userId); // Log userId separately
          console.log('message:', res.message); // Log message separately
          if (res.requiresTwoFactor) {
            // Ensure correct casing and check if true
            console.log('Requires 2FA:', res.requiresTwoFactor); // Log the 2FA requirement
            this.requiresTwoFactor = true;
            this.userId = res.userId ?? null;
            this.successMessage = res.message ?? null;
            console.log('UserId:', this.userId); // Log the userId
            if (this.userId !== null) {
              // Redirect to the 2FA page
              console.log('Redirecting to 2FA page'); // Log the redirection action
              this.router.navigate(['/2fa'], {
                queryParams: { userId: this.userId },
              });
            }
          } else {
            console.log('No 2FA required'); // Log if no 2FA is required
            this.authService.storeToken(res.token ?? ''); // Use AuthService to store the token
            this.router.navigate(['/dashboard']);
          }
        },
        error: (err) => {
          this.errorMessage =
            'Error: ' + (err.error.message ?? 'Unknown error');
          this.successMessage = null;
        },
      });
    }
  }

  private markAllAsTouched() {
    this.loginForm.markAllAsTouched();
  }
}
