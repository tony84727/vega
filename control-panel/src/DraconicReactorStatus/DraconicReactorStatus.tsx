import React from "react";
import { IDraconicReactorStatusProps } from "../IDraconicReactorStatusProps";
import { Grid } from "@material-ui/core";
import ValueDisplay from "./ValueDisplay";

export default function DraconicReactorStatus({
  fieldStrength,
  temperature,
  efficiency,
  energy,
}: IDraconicReactorStatusProps): React.ReactElement {
  return (
    <Grid container direction={"column"}>
      <Grid item>
        <ValueDisplay title={"溫度"} color={"#ff6700"} value={temperature} />
      </Grid>
      <Grid item>
        <ValueDisplay
          title={"遏制力場強度"}
          color={"#4d84ff"}
          value={fieldStrength}
        />
      </Grid>
      <Grid item>
        <ValueDisplay title={"能量飽和度"} color={"#00ff73"} value={energy} />
      </Grid>
      <Grid item>
        <ValueDisplay title={"轉換效率"} color={"#c17cb1"} value={efficiency} />
      </Grid>
    </Grid>
  );
}
