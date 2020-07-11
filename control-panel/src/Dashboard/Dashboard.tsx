import { IDashboardProps } from "../IDashboardProps";
import { Grid } from "@material-ui/core";
import SiteMap from "../SiteMap/SiteMap";
import Panel from "./Panel";
import PowerSourceChart from "../PowerSourceChart";
import SwitchBoard from "../SwitchBoard/SwitchBoard";
import { makeStyles } from "@material-ui/core/styles";
import DraconicReactorPanel from "./DraconicReactorPanel";

const useStyles = makeStyles({
  container: {
    padding: "2px",
  },
});

export function Dashboard({
  powerSourceData,
  siteData,
  infraSwitches,
  generatorSwitches,
  draconicReactors,
}: IDashboardProps) {
  const styles = useStyles();
  return (
    <Grid container className={styles.container}>
      <Grid container direction={"row"} justify={"space-evenly"} spacing={2}>
        <Grid item xs={12} md={3}>
          <Panel title={"電力來源"}>
            <PowerSourceChart powerSourceData={powerSourceData} />
          </Panel>
        </Grid>
        <Grid item xs={12} md={4}>
          <Panel title={"基礎設施"}>
            <SiteMap data={siteData} />
          </Panel>
        </Grid>
        <Grid item container direction={"column"} xs={12} md={4} spacing={2}>
          <Grid item>
            <Panel title={"設施斷路器"}>
              <SwitchBoard switches={infraSwitches} />
            </Panel>
          </Grid>
          <Grid item>
            <Panel title={"發電廠斷路器"}>
              <SwitchBoard switches={generatorSwitches} />
            </Panel>
          </Grid>
          <Grid item container spacing={1}>
            {draconicReactors.map((reactor) => (
              <Grid item md={6} lg={3}>
                <DraconicReactorPanel {...reactor} />
              </Grid>
            ))}
          </Grid>
        </Grid>
      </Grid>
    </Grid>
  );
}
