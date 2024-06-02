import { Component, OnInit } from '@angular/core';
import { ProductDTO } from '../../models/ProductDTO';
import { CategoryDTO } from '../../models/CategoryDTO';
import { ProductService } from '../../services/product.service';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

@Component({
  selector: 'app-products-list',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './products-list.component.html',
  styleUrl: './products-list.component.css',
})
export class ProductsListComponent implements OnInit {
  products: ProductDTO[] = [];
  categories: CategoryDTO[] = [];
  categoryMap: { [key: number]: string } = {};

  constructor(private productService: ProductService, private router: Router) {}

  ngOnInit(): void {
    this.loadCategories();
    this.loadProducts();
  }

  private loadCategories(): void {
    this.productService.getCategories().subscribe((categories) => {
      this.categories = categories;
      this.categoryMap = this.categories.reduce(
        (map: { [key: number]: string }, category) => {
          map[category.categoryId] = category.categoryName;
          return map;
        },
        {}
      );
    });
  }

  private loadProducts(): void {
    this.productService.getAllProducts().subscribe((products) => {
      this.products = products;
    });
  }

  getCategoryName(categoryId: number): string {
    return this.categoryMap[categoryId] || 'Unknown';
  }

  editProduct(product: ProductDTO): void {
    // Placeholder for edit product logic
    console.log('Edit product', product);
  }

  viewProductDetails(product: ProductDTO): void {
    // Placeholder for view product details logic
    console.log('View product details', product);
    this.router.navigate(['/product-details', product.productId]);
  }

  deleteProduct(productId: number): void {
    // Placeholder for delete product logic
    console.log('Delete product with ID', productId);
  }
}
