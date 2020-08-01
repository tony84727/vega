import React from "react";
import { IDashboardProps } from "../IDashboardProps";
import { Grid } from "@material-ui/core";
import SiteMap from "../SiteMap/SiteMap";
import Panel from "./Panel";
import PowerSourceChart from "../PowerSourceChart";
import SwitchBoard from "../SwitchBoard/SwitchBoard";
import { makeStyles } from "@material-ui/core/styles";
import DraconicReactorPanel from "./DraconicReactorPanel";
import MessageDisplay from "../MessageDisplay/MessageDisplay";

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
  messageLines,
}: IDashboardProps): React.ReactElement {
  const styles = useStyles();
  return (
    <Grid container className={styles.container}>
      <Grid container direction={"row"} spacing={2}>
        <Grid container item xs={12} md={3} direction={"column"} spacing={2}>
          <Grid item>
            <Panel title={"電力來源"}>
              <PowerSourceChart powerSourceData={powerSourceData} />
            </Panel>
          </Grid>
          <Grid item>
            <Panel title={"訊息"}>
              <MessageDisplay lines={messageLines} />
            </Panel>
          </Grid>
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
              <Grid key={reactor.name} item md={6} lg={3}>
                <DraconicReactorPanel {...reactor} />
              </Grid>
            ))}
          </Grid>
        </Grid>
      </Grid>
    </Grid>
  );
}
