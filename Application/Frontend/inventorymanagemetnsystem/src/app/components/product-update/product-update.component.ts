import { Component, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { ProductService } from '../../services/product.service';
import { ProductUpdateDTO } from '../../models/ProductUpdateDTO';
import { CommonModule } from '@angular/common';
import { CategoryDTO } from '../../models/CategoryDTO';

@Component({
  selector: 'app-product-update',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule],
  templateUrl: './product-update.component.html',
  styleUrl: './product-update.component.css',
})
export class ProductUpdateComponent implements OnInit {
  productUpdateForm: FormGroup;
  productId!: number;
  version!: string;
  categories: CategoryDTO[] = [];
  successMessage: string | null = null;
  errorMessage: string | null = null;

  constructor(
    private fb: FormBuilder,
    private route: ActivatedRoute,
    private router: Router,
    private productService: ProductService
  ) {
    this.productUpdateForm = this.fb.group({
      productName: ['', [Validators.required, Validators.minLength(2)]],
      quantity: [
        0,
        [
          Validators.required,
          Validators.min(1),
          Validators.pattern('^[1-9]*$'),
        ],
      ],
      price: [0, [Validators.required, Validators.min(0.000000001)]],
      categoryId: ['', Validators.required],
      version: [''],
    });
  }

  ngOnInit(): void {
    this.productId = +this.route.snapshot.paramMap.get('id')!;
    this.loadProductDetails(this.productId);
    this.loadCategories();
  }

  private loadProductDetails(productId: number): void {
    this.productService.getAllProducts().subscribe((products) => {
      const product = products.find((p) => p.productId === productId);

      if (product) {
        this.productUpdateForm.patchValue({
          productName: product.productName,
          quantity: product.quantity,
          price: product.price,
          categoryId: product.categoryId,
        });
      } else {
        this.errorMessage = 'Product not found';
        this.router.navigate(['/products-list']);
      }
    });
  }

  private loadCategories(): void {
    this.productService.getCategories().subscribe((categories) => {
      this.categories = categories;
    });
  }

  updateProduct(): void {
    if (this.productUpdateForm.valid) {
      const productUpdateDTO: ProductUpdateDTO = {
        productId: this.productId,
        productName: this.productUpdateForm.value.productName,
        quantity: this.productUpdateForm.value.quantity,
        price: this.productUpdateForm.value.price,
        categoryId: this.productUpdateForm.value.categoryId,
        version: this.version,
      };

      this.productService.updateProduct(productUpdateDTO).subscribe(
        () => {
          this.successMessage = 'Product updated successfully';
          //this.router.navigate(['/products-list']);
        },
        (error) => {
          console.error('Error updating product', error);
          this.errorMessage = 'Error updating product. Please try again.';
        }
      );
    }
  }

  goBack(): void {
    this.router.navigate(['/products-list']);
  }
}
