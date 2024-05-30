import { HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, throwError } from 'rxjs';
import { environment } from '../environments/environment';

export const API_URL = environment.apiURL;

@Injectable({
  providedIn: 'root',
})
export abstract class SharedService {
  constructor() {}

  /**
   * Http error handler
   * @param err http error from the http request
   * @returns The exception
   */
  protected handleError(err: HttpErrorResponse): Observable<never> {
    //Network based errors
    if (err.error instanceof ProgressEvent) {
      console.log('Progress event error detected');

      return throwError(() => new Error('Error connection to REST Server'));
    }

    // Server side errors
    return throwError(() => err);
  }
}
