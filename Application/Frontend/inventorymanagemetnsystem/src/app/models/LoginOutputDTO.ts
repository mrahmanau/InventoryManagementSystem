export class LoginOutputDTO {
  userId: number | null = null;
  token: string | null = null;
  expiresIn: number = 0;
  requiresTwoFactor: boolean = false;
  message: string | null = null;
}
