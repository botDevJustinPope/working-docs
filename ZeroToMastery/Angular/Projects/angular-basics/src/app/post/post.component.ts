import { Component, input, output, OnInit } from '@angular/core';

@Component({
  selector: 'app-post',
  standalone: true,
  imports: [],
  templateUrl: './post.component.html',
  styleUrl: './post.component.scss'
})
export class PostComponent implements OnInit {
  postImage = input.required<string>();
  imageSelected = output<string>();

  constructor() {
    console.log('PostComponent.constructor()');
  }

  ngOnInit() {
    console.log('PostComponent.ngOnInit()', this.postImage());
  }
}
