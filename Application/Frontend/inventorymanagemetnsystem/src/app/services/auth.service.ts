import { Injectable } from '@angular/core';
import { API_URL } from './shared.service';
import { Observable } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { UserRegistrationDTO } from '../models/UserRegistrationDTO';
import { UserLoginDTO } from '../models/UserLoginDTO';
import { JwtHelperService } from '@auth0/angular-jwt';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private jwtHelper = new JwtHelperService();
  constructor(private http: HttpClient) {}

  register(user: UserRegistrationDTO): Observable<any> {
    return this.http.post(`${API_URL}/auth/register`, user);
  }

  login(user: UserLoginDTO): Observable<any> {
    return this.http.post(`${API_URL}/auth/login`, user);
  }

  // Store the token in local storage
  storeToken(token: string): void {
    localStorage.setItem('token', token);
  }

  // Retrieve the token from local storage
  getToken(): string | null {
    return localStorage.getItem('token');
  }

  // Check if the user is authenticated
  isAuthenticated(): boolean {
    //return this.getToken() !== null;
    const token = this.getToken();

    return token !== null && !this.jwtHelper.isTokenExpired(token);
  }

  isTokenExpired(): boolean {
    const token = this.getToken();
    return token ? this.jwtHelper.isTokenExpired(token) : true;
  }

  // Remove the token from local storage (logout)
  logout(): void {
    localStorage.removeItem('token');
  }
}
