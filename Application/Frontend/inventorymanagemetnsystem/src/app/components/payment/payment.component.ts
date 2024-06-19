import { Component, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import {
  Stripe,
  StripeCardCvcElement,
  StripeCardElement,
  StripeCardExpiryElement,
  StripeCardNumberElement,
  StripeElements,
  loadStripe,
} from '@stripe/stripe-js';
import { PaymentService } from '../../services/payment.service';
import { StripeService } from '../../services/stripe.service';
import { CommonModule, DecimalPipe } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-payment',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  providers: [DecimalPipe],

  templateUrl: './payment.component.html',
  styleUrl: './payment.component.css',
})
export class PaymentComponent implements OnInit {
  paymentForm: FormGroup;
  stripe: Stripe | null = null;
  elements: StripeElements | null = null;
  cardNumber: StripeCardNumberElement | null = null;
  cardExpiry: StripeCardExpiryElement | null = null;
  cardCvc: StripeCardCvcElement | null = null;
  errorMessage: string | null = null;
  successMessage: string | null = null;
  cardNumberError: string | null = null;
  cardExpiryError: string | null = null;
  cardCvcError: string | null = null;
  isProcessing: boolean = false; // Track payment state

  constructor(
    private fb: FormBuilder,
    private paymentService: PaymentService,
    private stripeService: StripeService,
    private route: ActivatedRoute,
    private authService: AuthService, // Inject AuthService
    private decimalPipe: DecimalPipe // Inject DecimalPipe
  ) {
    this.paymentForm = this.fb.group({
      userId: [{ value: '', disabled: true }, Validators.required],
      amount: [
        { value: '', disabled: true },
        [Validators.required, Validators.min(1)],
      ],
    });
  }

  async ngOnInit() {
    this.stripe = await this.stripeService.getStripe();
    console.log('Stripe instance in ngOnInit:', this.stripe);

    if (this.stripe) {
      this.elements = this.stripe.elements();
      console.log('Elements instance in ngOnInit:', this.elements);

      const style = {
        base: {
          color: '#32325d',
          fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
          fontSmoothing: 'antialiased',
          fontSize: '16px',
          '::placeholder': {
            color: '#aab7c4',
          },
        },
        invalid: {
          color: '#fa755a',
          iconColor: '#fa755a',
        },
      };

      this.cardNumber = this.elements.create('cardNumber', { style: style });
      this.cardExpiry = this.elements.create('cardExpiry', { style: style });
      this.cardCvc = this.elements.create('cardCvc', { style: style });

      this.cardNumber.mount('#card-number-element');
      this.cardExpiry.mount('#card-expiry-element');
      this.cardCvc.mount('#card-cvc-element');

      // Add event listeners to handle validation errors
      this.cardNumber.on('change', (event) => {
        if (event.error) {
          this.cardNumberError = event.error.message;
        } else {
          this.cardNumberError = null;
        }
        this.clearMessages();
      });

      this.cardExpiry.on('change', (event) => {
        if (event.error) {
          this.cardExpiryError = event.error.message;
        } else {
          this.cardExpiryError = null;
        }
        this.clearMessages();
      });

      this.cardCvc.on('change', (event) => {
        if (event.error) {
          this.cardCvcError = event.error.message;
        } else {
          this.cardCvcError = null;
        }
        this.clearMessages();
      });
    } else {
      console.error('Stripe instance is null');
    }

    // Get userId from AuthService
    const userId = this.authService.getUserId();
    const amount = this.route.snapshot.queryParamMap.get('totalAmount');
    const formattedAmount = this.decimalPipe.transform(amount, '1.2-2');

    this.paymentForm.patchValue({ userId, amount: formattedAmount });
  }

  clearMessages() {
    this.errorMessage = null;
    this.successMessage = null;
  }

  async onSubmit() {
    this.paymentForm.markAllAsTouched();

    // Check for Stripe element errors before submitting
    if (
      this.paymentForm.invalid ||
      this.cardNumberError ||
      this.cardExpiryError ||
      this.cardCvcError
    ) {
      this.errorMessage = 'Please complete all required fields correctly.';
      return;
    }

    // Check if card elements are filled
    if (!this.cardNumber || !this.cardExpiry || !this.cardCvc) {
      this.errorMessage = 'Please complete all required fields.';
      return;
    }

    this.isProcessing = true; // Start processing

    const { userId, amount } = this.paymentForm.getRawValue(); // Use getRawValue to get the actual values from disabled controls

    // Convert amount from dollars to cents
    const amountInCents = parseFloat(amount) * 100;

    this.paymentService.createPaymentIntent(userId, amountInCents).subscribe(
      async (res) => {
        if (this.stripe && this.cardNumber && this.cardExpiry && this.cardCvc) {
          const { clientSecret } = res;

          try {
            const result = await this.stripe.confirmCardPayment(clientSecret, {
              payment_method: {
                card: this.cardNumber,
              },
            });

            if (result.error) {
              this.errorMessage =
                result.error.message ?? 'An unknown error occurred.';
              this.successMessage = null;
            } else {
              if (result.paymentIntent?.status === 'succeeded') {
                this.successMessage = 'Payment successful!';
                this.errorMessage = null;
              }
            }
          } catch (error) {
            this.errorMessage = 'An unknown error occurred.';
            this.successMessage = null;
          } finally {
            this.isProcessing = false; // Ensure isProcessing is reset
          }
        }
      },
      (error) => {
        this.errorMessage = error.error.message ?? 'An unknown error occurred.';
        this.successMessage = null;
        this.isProcessing = false; // Stop processing on error
      }
    );
  }
}
