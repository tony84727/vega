import { useCallback, useState } from "react";
import { EMPTY, fromEvent, merge, Observable } from "rxjs";
import { map, takeUntil, tap } from "rxjs/operators";
import { WebSocketMessage } from "rxjs/internal/observable/dom/WebSocketSubject";

export default function useWebsocket(websocketHost: string) {
  const [socket] = useState(() =>
    process.browser ? new WebSocket(websocketHost) : undefined
  );
  const [message$] = useState(() => {
    if (socket === undefined) {
      return EMPTY;
    }
    const message$ = fromEvent(socket, "message") as Observable<MessageEvent>;
    const error$ = fromEvent(socket, "error");
    const close$ = fromEvent(socket, "close") as Observable<CloseEvent>;

    return merge(
      message$,
      error$.pipe(
        map((x) => {
          throw x;
        })
      )
    ).pipe(takeUntil(close$));
  });
  const send = useCallback(
    (message: WebSocketMessage) => socket.send(message),
    [socket]
  );
  return {
    message$,
    send,
  };
}
