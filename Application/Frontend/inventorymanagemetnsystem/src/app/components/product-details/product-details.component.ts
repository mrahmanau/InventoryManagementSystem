import { Component, OnInit } from '@angular/core';
import { ProductDTO } from '../../models/ProductDTO';
import { ActivatedRoute, Router } from '@angular/router';
import { ProductService } from '../../services/product.service';
import { CommonModule } from '@angular/common';
import { CartService } from '../../services/cart.service';

@Component({
  selector: 'app-product-details',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './product-details.component.html',
  styleUrl: './product-details.component.css',
})
export class ProductDetailsComponent implements OnInit {
  product: ProductDTO | undefined;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private productService: ProductService,
    private cartService: CartService
  ) {}

  ngOnInit(): void {
    const productId = Number(this.route.snapshot.paramMap.get('id'));
    this.loadProductDetails(productId);
  }

  private loadProductDetails(productId: number): void {
    this.productService.getAllProducts().subscribe((products) => {
      this.product = products.find(
        (product) => product.productId === productId
      );
    });
  }

  goBack(): void {
    this.router.navigate(['/products-list']);
  }

  addToCart(): void {
    if (this.product) {
      this.cartService.addToCart(this.product);
      this.router.navigate(['/cart']);
    }
  }
}
