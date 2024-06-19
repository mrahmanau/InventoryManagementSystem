import { Injectable } from '@angular/core';
import { ProductDTO } from '../models/ProductDTO';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class CartService {
  private cartItems: ProductDTO[] = [];
  private cartItemsSubject: BehaviorSubject<ProductDTO[]> = new BehaviorSubject<
    ProductDTO[]
  >([]);

  constructor() {}

  getCartItems(): Observable<ProductDTO[]> {
    return this.cartItemsSubject.asObservable();
  }

  addToCart(product: ProductDTO): void {
    const existingProduct = this.cartItems.find(
      (item) => item.productId === product.productId
    );
    if (existingProduct) {
      existingProduct.quantity += 1;
    } else {
      this.cartItems.push({ ...product, quantity: 1 });
    }
    this.cartItemsSubject.next(this.cartItems);
  }

  updateQuantity(productId: number, quantity: number): void {
    const product = this.cartItems.find((item) => item.productId === productId);
    if (product) {
      product.quantity = quantity;
      this.cartItemsSubject.next(this.cartItems);
    }
  }

  clearCart(): void {
    this.cartItems = [];
    this.cartItemsSubject.next(this.cartItems);
  }
}
