import { Injectable } from '@angular/core';
import { Stripe, loadStripe } from '@stripe/stripe-js';

@Injectable({
  providedIn: 'root',
})
export class StripeService {
  private stripePromise: Promise<Stripe | null>;

  constructor() {
    this.stripePromise = this.initializeStripe();
  }

  private async initializeStripe(): Promise<Stripe | null> {
    const stripe = await loadStripe(
      'pk_test_51PRl1HP5Rori6giQAAjCXWLdt8kodduiNW0ydplnoTEVqqUKq4rjBnDZJ7m0mN1ERAH8vdZAP8StomCb6v0yno2X00Hrd7NOtV'
    );
    console.log('Stripe initialized:', stripe);
    return stripe;
  }

  public async getStripe(): Promise<Stripe | null> {
    return this.stripePromise;
  }
}
