import { useCallback, useState } from "react";
import { fromEvent, merge, Observable } from "rxjs";
import { map, takeUntil } from "rxjs/operators";
import { WebSocketMessage } from "rxjs/internal/observable/dom/WebSocketSubject";

export default function useWebsocket(websocketHost: string) {
  const [socket] = useState(new WebSocket(websocketHost));
  const [message$] = useState(() => {
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
