import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Contact } from '../models/ContactDTO';
import { API_URL } from './shared.service';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ContactService {
  constructor(private http: HttpClient) {}

  sendContactMessage(contact: Contact): Observable<any> {
    return this.http.post<any>(`${API_URL}/Contact/contact`, contact);
  }
}
