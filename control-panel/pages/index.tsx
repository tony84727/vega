import MockPowerDashboard from "../src/MockPowerDashboard";
import { Grid } from "@material-ui/core";
import { makeStyles } from "@material-ui/core/styles";

const useStyles = makeStyles({
  container: {
    background:
      "linear-gradient(90deg, rgba(0,63,116,1) 0%, rgba(15,35,96,1) 43%, rgba(2,2,47,1) 100%)",
    height: "100%",
  },
});

export default function Home() {
  const styles = useStyles();
  return (
    <Grid className={styles.container}>
      <MockPowerDashboard />
    </Grid>
  );
}
