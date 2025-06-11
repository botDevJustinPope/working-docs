import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SVGLoaderComponent } from './svg-loader.component';

describe('SVGLoaderComponent', () => {
  let component: SVGLoaderComponent;
  let fixture: ComponentFixture<SVGLoaderComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SVGLoaderComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(SVGLoaderComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
