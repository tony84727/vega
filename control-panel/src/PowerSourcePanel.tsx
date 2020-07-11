import { Card, Grid } from "@material-ui/core";
import PowerSourceChart, { IPowerSourceChartProps } from "./PowerSourceChart";
import { makeStyles } from "@material-ui/core/styles";

const useStyles = makeStyles({
  container: {
    padding: "16px",
  },
});

export function PowerSourcePanel({ powerSourceData }: IPowerSourceChartProps) {
  const styles = useStyles();
  return (
    <Grid container>
      <Card className={styles.container}>
        <PowerSourceChart powerSourceData={powerSourceData} />
      </Card>
    </Grid>
  );
}
