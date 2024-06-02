import { Component, OnInit } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { CategoryDTO } from '../../models/CategoryDTO';
import { ProductService } from '../../services/product.service';
import { ProductDTO } from '../../models/ProductDTO';
import { error } from 'console';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-add-product',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule],
  templateUrl: './add-product.component.html',
  styleUrl: './add-product.component.css',
})
export class AddProductComponent implements OnInit {
  addProductForm: FormGroup;
  categories: CategoryDTO[] = [];
  successMessage: string | null = null;
  errorMessage: string | null = null;

  constructor(private fb: FormBuilder, private productService: ProductService) {
    this.addProductForm = this.fb.group({
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
    });
  }

  ngOnInit() {
    this.productService.getCategories().subscribe(
      (data) => {
        this.categories = data;
      },
      (error) => {
        this.errorMessage = 'Error fetching categories: ' + error.message;
      }
    );

    this.addProductForm.valueChanges.subscribe(() => {
      this.successMessage = null;
      this.errorMessage = null;
    });
  }

  onSubmit() {
    if (this.addProductForm.valid) {
      const product: ProductDTO = this.addProductForm.value;
      this.productService.addProduct(product).subscribe(
        (response: any) => {
          this.successMessage = response.message;
          this.errorMessage = null;
          this.addProductForm.reset();
          this.markFormControlsAsUnTouched();
        },
        (error) => {
          this.successMessage = null;
          this.errorMessage = error.error.message;
        }
      );
    } else {
      this.markFormControlsAsTouched();
    }
  }

  private markFormControlsAsTouched() {
    Object.keys(this.addProductForm.controls).forEach((control) => {
      this.addProductForm.controls[control].markAsTouched();
    });
  }

  private markFormControlsAsUnTouched() {
    Object.keys(this.addProductForm.controls).forEach((control) => {
      this.addProductForm.controls[control].markAsUntouched();
    });
  }
}
