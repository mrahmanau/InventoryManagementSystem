import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { ProductDTO } from '../../models/ProductDTO';
import { CartService } from '../../services/cart.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-cart',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './cart.component.html',
  styleUrl: './cart.component.css',
})
export class CartComponent implements OnInit {
  cartItems: ProductDTO[] = [];
  cartForm: FormGroup;

  constructor(
    private cartService: CartService,
    private fb: FormBuilder,
    private router: Router
  ) {
    this.cartForm = this.fb.group({});
  }

  ngOnInit(): void {
    this.cartService.getCartItems().subscribe((items) => {
      this.cartItems = items;
      this.initializeForm();
    });
  }

  initializeForm() {
    this.cartItems.forEach((item, index) => {
      this.cartForm.addControl(
        `quantity${index}`,
        this.fb.control(item.quantity)
      );
    });
  }

  updateQuantity(index: number) {
    const quantityControl = this.cartForm.get(`quantity${index}`);
    if (quantityControl) {
      this.cartService.updateQuantity(
        this.cartItems[index].productId,
        quantityControl.value
      );
    }
  }

  getSubtotal(): number {
    return this.cartItems.reduce(
      (sum, item) => sum + item.price * item.quantity,
      0
    );
  }

  getSalesTax(): number {
    return this.getSubtotal() * 0.1; // Assume a sales tax rate of 10%
  }

  getGrandTotal(): number {
    return this.getSubtotal() + this.getSalesTax();
  }

  checkout() {
    const userId = 1; // Replace with the actual user ID from your authentication system
    const totalAmount = this.getGrandTotal();
    this.router.navigate(['/payment'], {
      queryParams: { userId, totalAmount },
    });
  }
}
