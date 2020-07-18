import { useCallback, useState } from "react";
import { fromEvent, merge, Observable } from "rxjs";
import { map, takeUntil } from "rxjs/operators";
import { WebSocketMessage } from "rxjs/internal/observable/dom/WebSocketSubject";
import { webSocket } from "rxjs/webSocket";

export default function useWebsocket(websocketHost: string) {
  const [websocket$] = useState(() => webSocket(websocketHost));
  const send = useCallback(
    (message: WebSocketMessage) => websocket$.next(message),
    [websocket$]
  );
  return {
    websocket$,
    send,
  };
}
