var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        if (typeof b !== "function" && b !== null)
            throw new TypeError("Class extends value " + String(b) + " is not a constructor or null");
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var MenuItem = /** @class */ (function () {
    function MenuItem(id) {
        this.id = id;
    }
    return MenuItem;
}());
var Pizza = /** @class */ (function (_super) {
    __extends(Pizza, _super);
    function Pizza() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    return Pizza;
}(MenuItem));
var Hamburger = /** @class */ (function (_super) {
    __extends(Hamburger, _super);
    function Hamburger() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    return Hamburger;
}(MenuItem));
console.log(new Pizza('abc'));
console.log(new Hamburger('def'));
