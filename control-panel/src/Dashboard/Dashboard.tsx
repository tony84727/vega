import { IDashboardProps } from "../IDashboardProps";
import { Grid } from "@material-ui/core";
import SiteMap from "../SiteMap/SiteMap";
import Panel from "./Panel";
import PowerSourceChart from "../PowerSourceChart";

export function Dashboard({ powerSourceData, siteData }: IDashboardProps) {
  return (
    <Grid container>
      <Grid container direction={"row"} wrap={"nowrap"}>
        <Grid item>
          <Panel title={"電力來源"}>
            <PowerSourceChart powerSourceData={powerSourceData} />
          </Panel>
        </Grid>
        <Grid item>
          <Panel title={"基礎設施"}>
            <SiteMap data={siteData} />
          </Panel>
        </Grid>
      </Grid>
    </Grid>
  );
}
