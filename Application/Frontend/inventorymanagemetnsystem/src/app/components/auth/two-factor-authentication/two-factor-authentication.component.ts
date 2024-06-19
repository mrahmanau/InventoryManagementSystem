import { Component } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { AuthService } from '../../../services/auth.service';
import { ActivatedRoute, Router } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-two-factor-authentication',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './two-factor-authentication.component.html',
  styleUrl: './two-factor-authentication.component.css',
})
export class TwoFactorAuthenticationComponent {
  twoFactorForm: FormGroup;
  errorMessage: string | null = null;
  userId: number | null = null;

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private route: ActivatedRoute,
    private router: Router
  ) {
    this.twoFactorForm = this.fb.group({
      twoFactorCode: ['', Validators.required],
    });
  }

  ngOnInit(): void {
    this.route.queryParams.subscribe((params) => {
      this.userId = +params['userId'] || null;
    });
  }

  onSubmit() {
    if (this.twoFactorForm.invalid || this.userId === null) {
      return;
    }

    const twoFactorData = {
      UserId: this.userId,
      TwoFactorCode: this.twoFactorForm.get('twoFactorCode')?.value ?? '',
    };

    this.authService.verifyTwoFactorCode(twoFactorData).subscribe({
      next: (res) => {
        this.authService.storeToken(res.token ?? ''); // Use AuthService to store the token
        this.router.navigate(['/dashboard']);
      },
      error: (err) => {
        this.errorMessage = 'Error: ' + (err.error.message ?? 'Unknown error');
      },
    });
  }
}
