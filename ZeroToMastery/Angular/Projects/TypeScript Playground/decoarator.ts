function MenuItem(itemId: string) {
    return function (value, context) {
    return class extends value {
        id = itemId;
    };
    }
}

@MenuItem("abc")
class Pizza {
    id: string;
}

@MenuItem("def")
class Hamburger {
    id: string;
}

console.log(new Pizza());
console.log(new Hamburger());