import React from "react";
import MockDashboard from "../src/MockDashboard";
import { Grid } from "@material-ui/core";
import { makeStyles } from "@material-ui/core/styles";

const useStyles = makeStyles({
  container: {
    height: "100%",
  },
});

export default function Home(): React.ReactElement {
  const styles = useStyles();
  return (
    <Grid className={styles.container}>
      <MockDashboard />
    </Grid>
  );
}
