import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { ProductDTO } from '../models/ProductDTO';
import { Observable } from 'rxjs';
import { API_URL } from './shared.service';
import { CategoryDTO } from '../models/CategoryDTO';
import { ProductUpdateDTO } from '../models/ProductUpdateDTO';

@Injectable({
  providedIn: 'root',
})
export class ProductService {
  constructor(private http: HttpClient) {}

  addProduct(product: ProductDTO): Observable<void> {
    return this.http.post<void>(`${API_URL}/Product`, product);
  }

  getCategories(): Observable<CategoryDTO[]> {
    return this.http.get<CategoryDTO[]>(`${API_URL}/Categories`);
  }

  getAllProducts(): Observable<ProductDTO[]> {
    return this.http.get<ProductDTO[]>(`${API_URL}/Product`);
  }

  updateProduct(productUpdateDTO: ProductUpdateDTO): Observable<any> {
    return this.http.put<any>(`${API_URL}/Product/edit`, productUpdateDTO);
  }

  deleteProduct(productId: number): Observable<void> {
    return this.http.delete<void>(`${API_URL}/Product/${productId}`);
  }
}
