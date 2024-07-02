import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-email-confirmation',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './email-confirmation.component.html',
  styleUrl: './email-confirmation.component.css',
})
export class EmailConfirmationComponent implements OnInit {
  message: string = '';
  isSuccess: boolean = false;

  constructor(
    private route: ActivatedRoute,
    private authService: AuthService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.route.queryParams.subscribe((params) => {
      const token = params['token'];
      if (token) {
        this.authService.confirmEmail(token).subscribe(
          (response) => {
            this.message = response;
            this.isSuccess = true;
            setTimeout(() => {
              this.router.navigate(['/login']);
            }, 3000);
          },
          (error) => {
            this.message = error.error;
            this.isSuccess = false;
          }
        );
      } else {
        this.message = 'No token provided';
        this.isSuccess = false;
      }
    });
  }
}
