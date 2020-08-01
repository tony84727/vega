import React from "react";
import { Typography } from "@material-ui/core";
import Bar from "../Bar";
import IValueDisplayProps from "./IValueDisplayProps";

export default function ValueDisplay({
  title,
  value,
  color,
}: IValueDisplayProps): React.ReactElement {
  return (
    <>
      <Typography color={"textSecondary"}>{title}</Typography>
      <Bar
        variant={"determinate"}
        value={value}
        highContrast={true}
        barColor={color}
      />
    </>
  );
}
