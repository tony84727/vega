import MockPowerDashboard from "../src/MockPowerDashboard";
import { Grid } from "@material-ui/core";
import { makeStyles } from "@material-ui/core/styles";
import SiteMap from "../src/SiteMap";
import { links, sites } from "../src/siteMapMockData";

const useStyles = makeStyles({
  container: {
    height: "100%",
  },
});

export default function Home() {
  const styles = useStyles();
  return (
    <Grid className={styles.container}>
      <MockPowerDashboard />
      <SiteMap sites={sites} powerLinks={links} />
    </Grid>
  );
}
