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
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('token', token);
    }
  }

  // Retrieve the token from local storage
  getToken(): string | null {
    if (typeof localStorage !== 'undefined') {
      return localStorage.getItem('token');
    }
    return null;
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

  // Get user role
  getUserRole(): string | null {
    const token = this.getToken();
    if (token) {
      const decodedToken = this.jwtHelper.decodeToken(token);
      return decodedToken?.role || null; // Retrieve role from token
    }
    return null;
  }

  // Get user first name
  getUserFirstName(): string | null {
    const token = this.getToken();
    if (token) {
      const decodedToken = this.jwtHelper.decodeToken(token);
      console.log('Decoded Token:', decodedToken);

      return decodedToken?.FirstName || null;
    }
    return null;
  }

  // Get user last name
  getUserLastName(): string | null {
    const token = this.getToken();
    if (token) {
      const decodedToken = this.jwtHelper.decodeToken(token);
      console.log('Decoded Token:', decodedToken);
      return decodedToken?.LastName || null;
    }
    return null;
  }

  // Get user email
  getUserEmail(): string | null {
    const token = this.getToken();
    if (token) {
      const decodedToken = this.jwtHelper.decodeToken(token);
      return decodedToken?.email || null;
    }
    return null;
  }

  // Remove the token from local storage (logout)
  logout(): void {
    if (typeof localStorage !== 'undefined') {
      localStorage.removeItem('token');
    }
  }
}
