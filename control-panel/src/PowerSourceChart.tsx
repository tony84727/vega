import { DiscreteColorLegend, Hint, Sunburst, SunburstPoint } from "react-vis";
import { Grid } from "@material-ui/core";
import { useMemo } from "react";
import { makeStyles } from "@material-ui/core/styles";

const colors = {
  神龍反應堆: "#ff6620",
  太陽能: "#dada38",
  偷鄰居的: "#e426ff",
};

function decorateData(powerSourceData: SunburstPoint) {
  return {
    ...powerSourceData,
    children: powerSourceData.children
      .map((c) =>
        c.title in colors ? { ...c, style: { fill: colors[c.title] } } : c
      )
      .map((x) => ({
        ...x,
        label: x.title,
        dontRotateLabel: true,
        labelStyle: {
          fill: "#fff",
        },
      })),
  };
}

export interface IPowerSourceChartProps {
  powerSourceData: SunburstPoint;
}
const useStyles = makeStyles({
  container: {
    padding: "8px",
  },
  legend: {
    color: "#fff",
  },
});
export default function PowerSourceChart({
  powerSourceData,
}: IPowerSourceChartProps) {
  const styles = useStyles();
  const decorated = useMemo(() => decorateData(powerSourceData), [
    powerSourceData,
  ]);
  const legends = useMemo(
    () => Object.keys(colors).map((title) => ({ title, color: colors[title] })),
    []
  );
  const sum = powerSourceData.children.reduce((acc, c) => acc + c.size, 0);
  return (
    <Grid container>
      <Sunburst
        data={decorated}
        height={250}
        width={300}
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
  );
}
