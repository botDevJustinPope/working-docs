import { v4 as uuid } from 'uuid';
import { computed } from '@angular/core';

export class FileData {
    
        public id: string = '';
        public path = computed(() => `clips/${this.id}.mp4` );
        public file: File;

        constructor(file: File){
                this.id = uuid();
                this.file = file;
        }
}