import { VictoryArea, VictoryChart, VictoryContainer } from "victory";
import { useMemo } from "react";

interface ISiteConsumption {
  dataPoints: [number, number][];
}

export default function SiteConsumption({ dataPoints }: ISiteConsumption) {
  const data = useMemo(() => dataPoints.map(([x, y]) => ({ x, y })), [
    dataPoints,
  ]);
  return (
    <VictoryChart>
      <VictoryArea data={data} />
    </VictoryChart>
  );
}
