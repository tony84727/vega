import { Card, Grid, Typography } from "@material-ui/core";
import PowerSourceChart, { IPowerSourceChartProps } from "./PowerSourceChart";
import { makeStyles } from "@material-ui/core/styles";
import SiteMap from "./SiteMap";
import { links, sites } from "./siteMapMockData";

const useStyles = makeStyles({
  container: {
    padding: "16px",
  },
});

export default function PowerDashboard({
  powerSourceData,
}: IPowerSourceChartProps) {
  const styles = useStyles();
  return (
    <Grid container={true} direction={"row"} className={styles.container}>
      <Typography variant={"h3"} color={"primary"}>
        電力監控
      </Typography>
      <Grid container={true}>
        <Card className={styles.container}>
          <PowerSourceChart powerSourceData={powerSourceData} />
        </Card>
        <SiteMap sites={sites} powerLinks={links} />
      </Grid>
    </Grid>
  );
}
