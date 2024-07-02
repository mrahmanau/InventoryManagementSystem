import { CommonModule } from '@angular/common';
import { isPlatformBrowser } from '@angular/common';
import {
  Component,
  AfterViewInit,
  HostListener,
  Renderer2,
  ElementRef,
  PLATFORM_ID,
  Inject,
} from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [ReactiveFormsModule, CommonModule],
  templateUrl: './home.component.html',
  styleUrl: './home.component.css',
})
export class HomeComponent implements AfterViewInit {
  selectedFeature: string | null = null;
  isBrowser: boolean;

  constructor(
    private renderer: Renderer2,
    private el: ElementRef,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {
    this.isBrowser = isPlatformBrowser(this.platformId);
  }

  ngAfterViewInit() {
    if (this.isBrowser) {
      this.addScrollAnimation();
    }
  }

  @HostListener('window:scroll', ['$event'])
  onWindowScroll() {
    if (this.isBrowser) {
      this.addScrollAnimation();
    }
  }

  addScrollAnimation() {
    const elements = this.el.nativeElement.querySelectorAll('.animate-text');
    const windowHeight = window.innerHeight;

    elements.forEach((element: any) => {
      const position = element.getBoundingClientRect().top;
      if (position < windowHeight - 50) {
        this.renderer.addClass(element, 'visible');
      }
    });
  }

  showDetails(feature: string) {
    this.selectedFeature = this.selectedFeature === feature ? null : feature;
  }
}
