import React from "react";
import { ISiteProps } from "./ISiteProps";
import Text from "./Text";

export default function Site({ name, color }: ISiteProps): React.ReactElement {
  return (
    <>
      <circle r={15} stroke={color} fill={"transparent"} strokeWidth={2} />
      <circle r={10} />
      <g transform={"translate(0, 30)"}>
        <Text>{name}</Text>
      </g>
    </>
  );
}
