import { Component, OnInit } from '@angular/core';
import { ProductDTO } from '../../models/ProductDTO';
import { CategoryDTO } from '../../models/CategoryDTO';
import { ProductService } from '../../services/product.service';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { NgxPaginationModule } from 'ngx-pagination';

@Component({
  selector: 'app-products-list',
  standalone: true,
  imports: [CommonModule, NgxPaginationModule],
  templateUrl: './products-list.component.html',
  styleUrl: './products-list.component.css',
})
export class ProductsListComponent implements OnInit {
  products: ProductDTO[] = [];
  categories: CategoryDTO[] = [];
  categoryMap: { [key: number]: string } = {};
  page: number = 1;
  pageSize: number = 6;
  successMessage: string | null = null;
  errorMessage: string | null = null;

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
    this.router.navigate(['/product-update', product.productId]);
  }

  viewProductDetails(product: ProductDTO): void {
    // Placeholder for view product details logic
    console.log('View product details', product);
    this.router.navigate(['/product-details', product.productId]);
  }

  deleteProduct(productId: number): void {
    // Placeholder for delete product logic
    if (confirm('Are you sure you want to delete this product?')) {
      console.log('Confirmed deletion for product with ID:', productId);
      this.productService.deleteProduct(productId).subscribe(
        () => {
          console.log('Product deleted successfully with ID:', productId);
          this.successMessage = 'Product deleted successfully';
          this.loadProducts();
        },
        (error) => {
          console.error('Error deleting product with ID:', productId, error);
          (this.errorMessage = 'Error deleting product. Please try again.'),
            error;
        }
      );
    }
  }
}
