import { Injectable } from '@angular/core';
import { AuthService } from '../../../services/auth.service';
import {
  ActivatedRouteSnapshot,
  CanActivate,
  Router,
  RouterStateSnapshot,
  UrlTree,
} from '@angular/router';

@Injectable({
  providedIn: 'root',
})
export class RoleGuard implements CanActivate {
  constructor(private authService: AuthService, private router: Router) {}

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): boolean | UrlTree {
    const expectedRole = route.data['expectedRole'];
    const userRole = this.authService.getUserRole();
    if (userRole === expectedRole) {
      return true;
    } else {
      return this.router.createUrlTree(['/login']);
    }
  }
}
