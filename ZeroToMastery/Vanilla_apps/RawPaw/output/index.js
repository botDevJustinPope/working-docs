import { interval } from "rxjs";
console.log("Ruff, Ruff, welcome to the junk yard!");
const observable = interval(1000);
const subscription = observable.subscribe({
    next(value) {
        console.log(value);
    },
    complete() {
        console.log("Completed");
    },
    error(err) {
        console.error(err);
    },
});
