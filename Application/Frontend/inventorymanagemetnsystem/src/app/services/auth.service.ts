import { Injectable } from '@angular/core';
import { API_URL } from './shared.service';
import { Observable } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { UserRegistrationDTO } from '../models/UserRegistrationDTO';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  constructor(private http: HttpClient) {}

  register(user: UserRegistrationDTO): Observable<any> {
    return this.http.post(`${API_URL}/auth/register`, user);
  }
}
