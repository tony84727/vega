import React from "react";
import { ISwitchBoardProps } from "./ISwitchBoardProps";
import { Grid } from "@material-ui/core";
import Switch from "./Switch";

export default function SwitchBoard({
  switches,
}: ISwitchBoardProps): React.ReactElement {
  return (
    <Grid container>
      {switches.map((x) => (
        <Grid item key={x.name} md={4}>
          <Switch switchData={x} />
        </Grid>
      ))}
    </Grid>
  );
}
