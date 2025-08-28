import "./components/consoleOutput/consoleOutput.ts";
import { fromEvent, of, interval } from "rxjs";
import { map, filter, reduce, take, scan, tap } from "rxjs/operators";

(async () => {
  await (window as any).ConsoleOutput.mount({
    anchor: "#console-output-anchor",
    hookEarly: true,
  });
  console.log("Ruff, Ruff, welcome to the junk yard!");
})();

const observable = interval(500).pipe(
  take(5),
  tap({
    next: console.log
  }),
  reduce((accumulator, current) => accumulator + current, 0)
);

const subscription = observable.subscribe({
  next(value) {
    console.log('value emitted:', value);
  },
  complete() {
    console.log('Done');
  }
});

console.log('after');