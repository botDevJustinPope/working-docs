import "./components/consoleOutput/consoleOutput.ts";
import { interval } from "rxjs";
import { takeUntil } from "rxjs/operators";

(async () => {
  await (window as any).ConsoleOutput.mount({
    anchor: "#console-output-anchor",
    hookEarly: true,
  });
  console.log("Ruff, Ruff, welcome to the junk yard!");
})();

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
