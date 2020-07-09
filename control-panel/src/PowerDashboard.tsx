import { Card, Grid, Typography } from "@material-ui/core";
import { DiscreteColorLegend, Sunburst, SunburstPoint } from "react-vis";
import { useMemo } from "react";
import { makeStyles } from "@material-ui/styles";
import ConsumptionBoard from "./ConsumptionBoard";

interface IPowerDashboardProps {
  powerSourceData: SunburstPoint;
}

const colors = {
  神龍反應堆: "#ff6620",
  太陽能: "#fff749",
  偷鄰居的: "#e426ff",
};

function decorateData(powerSourceData: SunburstPoint) {
  return {
    ...powerSourceData,
    children: powerSourceData.children.map((c) =>
      c.title in colors ? { ...c, style: { fill: colors[c.title] } } : c
    ),
  };
}

const useStyles = makeStyles({
  legend: {
    color: "#fff",
  },
  chartContainer: {
    padding: "16px",
  },
});

export default function PowerDashboard({
  powerSourceData,
}: IPowerDashboardProps) {
  const decorated = useMemo(() => decorateData(powerSourceData), [
    powerSourceData,
  ]);
  const legends = useMemo(
    () => Object.keys(colors).map((title) => ({ title, color: colors[title] })),
    []
  );
  const styles = useStyles();
  return (
    <Grid container={true} direction={"row"}>
      <Typography variant={"h3"} color={"primary"}>
        電力監控
      </Typography>
      <Grid container item>
        <Card className={styles.chartContainer}>
          <Grid container>
            <Sunburst
              data={decorated}
              height={250}
              width={250}
              hideRootNode={true}
              animation={true}
            />
            <Grid>
              <DiscreteColorLegend
                className={styles.legend}
                items={legends}
                orientation={"horizontal"}
              />
            </Grid>
          </Grid>
        </Card>
        <Grid>
          <ConsumptionBoard />
        </Grid>
      </Grid>
    </Grid>
  );
}