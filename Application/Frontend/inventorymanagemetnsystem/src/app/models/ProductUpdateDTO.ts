export interface ProductUpdateDTO {
  productId: number;
  productName: string;
  quantity: number;
  price: number;
  categoryId: number;
  version?: string;
}
