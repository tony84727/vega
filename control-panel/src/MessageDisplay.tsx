import { IMessageDisplay } from "./IMessageDisplay";
import { Typography } from "@material-ui/core";

export default function MessageDisplay({ lines }: IMessageDisplay) {
  return (
    <ol>
      {lines.map((l) => (
        <li key={l}>
          <Typography>{l}</Typography>
        </li>
      ))}
    </ol>
  );
}
