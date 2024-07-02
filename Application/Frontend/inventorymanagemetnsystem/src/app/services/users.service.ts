import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { UsersListDTO } from '../models/UserListDTO';
import { API_URL } from './shared.service';
import { UserDTO } from '../models/UserDTO';
import { EditProfileDTO } from '../models/EditProfileDTO';
import { EditPasswordDTO } from '../models/EditPasswordDTO';

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

  updateProfile(editProfileDto: EditProfileDTO): Observable<any> {
    return this.http.put(`${API_URL}/Users/update-profile`, editProfileDto);
  }

  updatePassword(editPasswordDTO: EditPasswordDTO): Observable<any> {
    return this.http.post(`${API_URL}/Auth/update-password`, editPasswordDTO);
  }
}
