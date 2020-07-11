import { IDashboardProps } from "./IDashboardProps";
import { Grid, Typography } from "@material-ui/core";
import { PowerSourcePanel } from "./PowerSourcePanel";
import SiteMap from "./SiteMap";
import { makeStyles } from "@material-ui/core/styles";

const useStyles = makeStyles({
  panelMargin: {
    margin: "0 8px",
  },
});

export function Dashboard({ powerSourceData, sites, links }: IDashboardProps) {
  const styles = useStyles();
  return (
    <Grid container>
      <Typography variant={"h3"} color={"primary"}>
        儀表板
      </Typography>
      <Grid container direction={"row"} wrap={"nowrap"}>
        <Grid item className={styles.panelMargin}>
          <PowerSourcePanel powerSourceData={powerSourceData} />
        </Grid>
        <Grid item className={styles.parnelMargin}>
          <SiteMap sites={sites} powerLinks={links} />
        </Grid>
      </Grid>
    </Grid>
  );
}
