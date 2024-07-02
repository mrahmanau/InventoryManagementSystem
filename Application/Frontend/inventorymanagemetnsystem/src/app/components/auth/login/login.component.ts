import { Component, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { AuthService } from '../../../services/auth.service';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { CommonModule } from '@angular/common';
import { LoginOutputDTO } from '../../../models/LoginOutputDTO';
import { ForgotPasswordDTO } from '../../../models/ForgotPasswordDTO ';
import { ResetPasswordDTO } from '../../../models/ResetPasswordDTO';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css',
})
export class LoginComponent implements OnInit {
  loginForm: FormGroup;
  forgotPasswordForm: FormGroup;
  resetPasswordForm: FormGroup;
  successMessage: string | null = null;
  errorMessage: string | null = null;
  requiresTwoFactor: boolean = false;
  userId: number | null = null;
  isForgotPassword: boolean = false;
  isForgotPasswordSubmitted: boolean = false;
  isResetPassword: boolean = false;
  resetToken: string | null = null;
  showPassword: boolean = false;
  passwordHasValue: boolean = false;

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private router: Router,
    private route: ActivatedRoute
  ) {
    this.loginForm = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required],
    });

    this.forgotPasswordForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
    });

    this.resetPasswordForm = this.fb.group({
      newPassword: ['', [Validators.required, Validators.minLength(8)]],
      confirmPassword: ['', [Validators.required, Validators.minLength(8)]],
    });
  }

  // onSubmit() {
  //   if (this.loginForm.invalid) {
  //     this.markAllAsTouched(this.loginForm);
  //     return;
  //   }
  //   // if (this.loginForm.valid) {
  //   //   this.authService.login(this.loginForm.value).subscribe({
  //   //     next: (res) => {
  //   //       //localStorage.setItem('token', res.token);
  //   //       this.authService.storeToken(res.token); // Use AuthService to store the token
  //   //       this.router.navigate(['/dashboard']);
  //   //     },
  //   //     error: (err) => {
  //   //       this.errorMessage = 'Error: ' + err.error.message;
  //   //       this.successMessage = null;
  //   //     },
  //   //   });
  //   // }
  //   if (this.loginForm.valid) {
  //     this.authService.login(this.loginForm.value).subscribe({
  //       next: (res: LoginOutputDTO) => {
  //         console.log('Login response:', res); // Log the entire response to the console
  //         console.log('requiresTwoFactor:', res.requiresTwoFactor); // Log requiresTwoFactor separately
  //         console.log('userId:', res.userId); // Log userId separately
  //         console.log('message:', res.message); // Log message separately
  //         if (res.requiresTwoFactor) {
  //           // Ensure correct casing and check if true
  //           console.log('Requires 2FA:', res.requiresTwoFactor); // Log the 2FA requirement
  //           this.requiresTwoFactor = true;
  //           this.userId = res.userId ?? null;
  //           this.successMessage = res.message ?? null;
  //           console.log('UserId:', this.userId); // Log the userId
  //           if (this.userId !== null) {
  //             // Redirect to the 2FA page
  //             console.log('Redirecting to 2FA page'); // Log the redirection action
  //             this.router.navigate(['/2fa'], {
  //               queryParams: { userId: this.userId },
  //             });
  //           }
  //         } else {
  //           console.log('No 2FA required'); // Log if no 2FA is required
  //           this.authService.storeToken(res.token ?? ''); // Use AuthService to store the token
  //           this.router.navigate(['/dashboard']);
  //         }
  //       },
  //       error: (err) => {
  //         this.errorMessage =
  //           'Error: ' + (err.error.message ?? 'Unknown error');
  //         this.successMessage = null;
  //       },
  //     });
  //   }
  // }

  // onForgotPasswordSubmit(): void {
  //   if (this.forgotPasswordForm.invalid) {
  //     this.markAllAsTouched(this.forgotPasswordForm);
  //     return;
  //   }
  //   const forgotPasswordData: ForgotPasswordDTO = this.forgotPasswordForm.value;
  //   this.authService.requestPasswordReset(forgotPasswordData).subscribe({
  //     next: (res) => {
  //       this.successMessage =
  //         'Reset password email sent. Please check your email.';
  //       this.errorMessage = null;
  //     },
  //     error: (err) => {
  //       this.errorMessage = 'Error: ' + err.error.message;
  //       this.successMessage = null;
  //     },
  //   });
  // }

  // private markAllAsTouched(form: FormGroup): void {
  //   Object.values(form.controls).forEach((control) => {
  //     control.markAsTouched();
  //   });
  // }

  ngOnInit(): void {
    this.route.queryParams.subscribe((params) => {
      this.resetToken = params['token'] || null;
      if (this.resetToken) {
        this.isResetPassword = true;
      }
    });
  }

  toggleForgotPassword(): void {
    this.isForgotPassword = !this.isForgotPassword;
    this.isForgotPasswordSubmitted = false;
    this.clearMessages();
  }

  toggleShowPassword(): void {
    this.showPassword = !this.showPassword;
  }

  onPasswordInput(): void {
    this.passwordHasValue = this.loginForm.get('password')?.value.length > 0;
  }

  onSubmit(): void {
    if (this.isResetPassword) {
      this.onResetPasswordSubmit();
    } else if (this.isForgotPassword) {
      this.onForgotPasswordSubmit();
    } else {
      this.onLoginSubmit();
    }
  }

  onLoginSubmit(): void {
    if (this.loginForm.invalid) {
      this.markAllAsTouched(this.loginForm);
      return;
    }
    if (this.loginForm.valid) {
      this.authService.login(this.loginForm.value).subscribe({
        next: (res: LoginOutputDTO) => {
          if (res.requiresTwoFactor) {
            this.requiresTwoFactor = true;
            this.userId = res.userId ?? null;
            this.successMessage = res.message ?? null;
            if (this.userId !== null) {
              this.router.navigate(['/2fa'], {
                queryParams: { userId: this.userId },
              });
            }
          } else {
            this.authService.storeToken(res.token ?? '');
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

  onForgotPasswordSubmit(): void {
    if (this.forgotPasswordForm.invalid) {
      this.markAllAsTouched(this.forgotPasswordForm);
      return;
    }
    const forgotPasswordData: ForgotPasswordDTO = this.forgotPasswordForm.value;
    this.authService.requestPasswordReset(forgotPasswordData).subscribe({
      next: (res) => {
        this.successMessage = 'Reset password email sent. ' + res.message;
        this.errorMessage = null;
        this.isForgotPasswordSubmitted = true;
      },
      error: (err) => {
        this.errorMessage = 'Error: ' + err.error.message;
        this.successMessage = null;
      },
    });
  }

  onResetPasswordSubmit(): void {
    if (this.resetPasswordForm.invalid) {
      this.markAllAsTouched(this.resetPasswordForm);
      return;
    }
    if (
      this.resetPasswordForm.value.newPassword !==
      this.resetPasswordForm.value.confirmPassword
    ) {
      this.errorMessage = 'Passwords do not match.';
      return;
    }
    const resetPasswordDTO: ResetPasswordDTO = {
      token: this.resetToken!,
      newPassword: this.resetPasswordForm.value.newPassword,
      confirmPassword: this.resetPasswordForm.value.confirmPassword,
    };

    this.authService.resetPassword(resetPasswordDTO).subscribe({
      next: (res) => {
        this.successMessage = res.message ?? 'Password reset successfully.';
        setTimeout(() => {
          this.router.navigate(['/login']);
        }, 3000);
      },
      error: (err) => {
        this.errorMessage = 'Error: ' + (err.error.message ?? 'Unknown error');
        this.successMessage = null;
      },
    });
  }

  private markAllAsTouched(form: FormGroup): void {
    Object.values(form.controls).forEach((control) => {
      control.markAsTouched();
    });
  }

  private clearMessages(): void {
    this.successMessage = null;
    this.errorMessage = null;
  }
}
