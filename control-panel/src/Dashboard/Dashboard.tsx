import { IDashboardProps } from "../IDashboardProps";
import { Grid, Typography } from "@material-ui/core";
import SiteMap from "../SiteMap/SiteMap";
import { makeStyles } from "@material-ui/core/styles";
import Panel from "./Panel";
import PowerSourceChart from "../PowerSourceChart";

const useStyles = makeStyles({
  panelMargin: {
    margin: "0 8px",
  },
});

export function Dashboard({ powerSourceData, siteData }: IDashboardProps) {
  const styles = useStyles();
  return (
    <Grid container>
      <Typography variant={"h3"} color={"primary"}>
        儀表板
      </Typography>
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
