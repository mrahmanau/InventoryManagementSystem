import { Component } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { ContactService } from '../../services/contact.service';
import { Contact } from '../../models/ContactDTO';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

@Component({
  selector: 'app-contact',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './contact.component.html',
  styleUrl: './contact.component.css',
})
export class ContactComponent {
  contactForm: FormGroup;
  successMessage: string | null = null;
  errorMessage: string | null = null;
  isLoading = false;

  constructor(private fb: FormBuilder, private contactService: ContactService) {
    this.contactForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(3)]],
      email: [
        '',
        [
          Validators.required,
          Validators.email,
          Validators.pattern(
            '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'
          ),
        ],
      ],
      subject: ['', [Validators.required, Validators.minLength(5)]],
      message: ['', [Validators.required, Validators.minLength(10)]],
    });
  }

  onSubmit(): void {
    if (this.contactForm.valid) {
      this.errorMessage = null;
      this.isLoading = true;
      const contact: Contact = this.contactForm.value;
      this.contactService.sendContactMessage(contact).subscribe({
        next: (response) => {
          this.successMessage =
            response?.message || 'Your message has been sent.';
          this.errorMessage = null;
          this.contactForm.reset();
          this.isLoading = false;
        },
        error: (error) => {
          this.errorMessage =
            error.error?.message || 'Error submitting the form';
          this.successMessage = null;
          this.isLoading = false;
        },
      });
    } else {
      this.markAllAsTouched();
      this.successMessage = null;
    }
  }

  private markAllAsTouched(): void {
    Object.values(this.contactForm.controls).forEach((control) => {
      control.markAsTouched();
    });
  }
}
