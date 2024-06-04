import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { ProductDTO } from '../../models/ProductDTO';
import { ProductService } from '../../services/product.service';
import { ProductSearchDTO } from '../../models/ProductSearchDTO';

@Component({
  selector: 'app-product-search',
  standalone: true,
  imports: [],
  templateUrl: './product-search.component.html',
  styleUrl: './product-search.component.css',
})
export class ProductSearchComponent implements OnInit {
  searchForm: FormGroup;
  products: ProductDTO[] = [];

  constructor(private fb: FormBuilder, private productService: ProductService) {
    this.searchForm = this.fb.group({
      productName: [''],
      categoryId: [''],
      minPrice: [''],
      maxPrice: [''],
    });
  }

  ngOnInit(): void {}

  onSubmit(): void {
    const searchCriteria: ProductSearchDTO = this.searchForm.value;
    this.productService.searchProduct(searchCriteria).subscribe(
      (data) => {
        this.products = data;
      },
      (error) => {
        console.error('Error searching products', error);
      }
    );
  }
}
