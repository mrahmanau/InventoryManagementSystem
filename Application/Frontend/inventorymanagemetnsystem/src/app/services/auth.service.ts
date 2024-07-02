import { Injectable } from '@angular/core';
import { API_URL } from './shared.service';
import { Observable, catchError, tap, throwError } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { UserRegistrationDTO } from '../models/UserRegistrationDTO';
import { UserLoginDTO } from '../models/UserLoginDTO';
import { JwtHelperService } from '@auth0/angular-jwt';
import { TwoFactorDTO } from '../models/TwoFactorDTO';
import { LoginOutputDTO } from '../models/LoginOutputDTO';
import { ForgotPasswordDTO } from '../models/ForgotPasswordDTO ';
import { ResetPasswordDTO } from '../models/ResetPasswordDTO';

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

  // Get user ID from token
  getUserId(): number | null {
    const token = this.getToken();
    if (token) {
      const decodedToken = this.jwtHelper.decodeToken(token);
      return decodedToken?.sub ? +decodedToken.sub : null;
    }
    return null;
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

  confirmEmail(token: string): Observable<any> {
    return this.http.get(`${API_URL}/Auth/confirm-email`, {
      params: { token },
      responseType: 'text',
    });
  }

  verifyTwoFactorCode(twoFactorData: TwoFactorDTO): Observable<LoginOutputDTO> {
    return this.http.post<LoginOutputDTO>(
      `${API_URL}/Auth/verify-2fa`,
      twoFactorData
    );
  }

  uploadProfileImage(file: File): Observable<any> {
    const formData = new FormData();
    formData.append('file', file);
    return this.http.post<any>(
      `${API_URL}/Auth/upload-profile-image`,
      formData
    );
  }

  requestPasswordReset(email: ForgotPasswordDTO): Observable<any> {
    return this.http.post(`${API_URL}/auth/request-password-reset`, email);
  }

  resetPassword(resetPasswordDTO: ResetPasswordDTO): Observable<any> {
    return this.http.post(`${API_URL}/auth/reset-password`, resetPasswordDTO);
  }
}
