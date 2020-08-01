import { WebSocketMessage } from "rxjs/internal/observable/dom/WebSocketSubject";
import { Observable } from "rxjs";

export interface IUseWebsocket {
  message$: Observable<MessageEvent>;
  send(message: WebSocketMessage): void;
}
