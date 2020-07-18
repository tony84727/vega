import { Observable, OperatorFunction } from "rxjs";
import { useEffect, useState } from "react";
import { scan } from "rxjs/operators";

function slidingWindow<I>(count: number): OperatorFunction<I, I[]> {
  return (source$) =>
    source$.pipe(scan((acc, c) => [c, ...acc.slice(0, count)], []));
}

export default function useDebuggingConsole(lines$: Observable<string>) {
  const [lines, setLines] = useState<string[]>([]);
  useEffect(() => {
    lines$.pipe(slidingWindow(20)).subscribe(setLines);
  }, [lines$]);
  return lines;
}
