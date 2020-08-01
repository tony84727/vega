import React, { useMemo } from "react";
import { VictoryArea, VictoryChart } from "victory";

interface ISiteConsumption {
  dataPoints: [number, number][];
}

export default function SiteConsumption({
  dataPoints,
}: ISiteConsumption): React.ReactElement {
  const data = useMemo(() => dataPoints.map(([x, y]) => ({ x, y })), [
    dataPoints,
  ]);
  return (
    <VictoryChart>
      <VictoryArea data={data} />
    </VictoryChart>
  );
}
