import SiteConsumption from "./SiteConsumption";
import { Grid } from "@material-ui/core";

export default function ConsumptionBoard() {
  return (
    <Grid container={true}>
      <Grid item>
        <SiteConsumption
          dataPoints={[
            [1, 1],
            [2, 2],
            [3, 3],
          ]}
        />
      </Grid>
    </Grid>
  );
}
