import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { API_URL } from './shared.service';

@Injectable({
  providedIn: 'root',
})
export class PaymentService {
  constructor(private http: HttpClient) {}

  createPaymentIntent(userId: number, amount: number): Observable<any> {
    return this.http.post(`${API_URL}/Payment/create-payment-intent`, {
      userId,
      amount,
    });
  }
}
