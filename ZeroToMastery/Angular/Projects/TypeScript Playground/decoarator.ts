
class MenuItem{
    id: string;
    constructor(id: string) {
        this.id = id;
    }
}

class Pizza extends MenuItem {}

class Hamburger extends MenuItem {}

console.log(new Pizza('abc'));
console.log(new Hamburger('def'));