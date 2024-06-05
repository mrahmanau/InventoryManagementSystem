import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { UsersListDTO } from '../models/UserListDTO';
import { API_URL } from './shared.service';
import { UserDTO } from '../models/UserDTO';

@Injectable({
  providedIn: 'root',
})
export class UsersService {
  constructor(private http: HttpClient) {}

  getUsers(): Observable<UsersListDTO[]> {
    return this.http.get<UsersListDTO[]>(`${API_URL}/Users`);
  }

  getUserById(userId: number): Observable<UserDTO> {
    return this.http.get<UserDTO>(`${API_URL}/Users/${userId}`);
  }

  deleteUser(userId: number): Observable<any> {
    return this.http.delete(`${API_URL}/Users/${userId}`, {
      responseType: 'text',
    });
  }

  updateUser(user: UserDTO): Observable<any> {
    return this.http.put(`${API_URL}/Users/${user.userId}`, user, {
      responseType: 'text',
    });
  }
}
