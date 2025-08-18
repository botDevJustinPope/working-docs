import { Component, input } from '@angular/core';
import { NgClass } from '@angular/common';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { provideNgxMask, NgxMaskDirective } from 'ngx-mask'

@Component({
  selector: 'app-input',
  standalone: true,
  imports: [ReactiveFormsModule, NgClass, NgxMaskDirective],
  templateUrl: './input.component.html',
  styleUrl: './input.component.scss',
  providers: [provideNgxMask()]
})
export class InputComponent {
  control = input.required<FormControl>();
  type = input('text');
  placeholder = input('');  
  format = input('');
}
