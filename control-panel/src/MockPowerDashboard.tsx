import React, { useEffect, useState } from "react";
import { of } from "rxjs";
import { SunburstPoint } from "react-vis";
import PowerDashboard from "./PowerDashboard";

export default function MockPowerDashboard() {
  const [powerSourceData, setPowerSourceData] = useState<SunburstPoint>({
    title: "root",
    size: 0,
    children: [],
  });
  useEffect(() => {
    const sub = of({
      title: "root",
      size: 0,
      children: [
        {
          title: "神龍反應堆",
          size: 1870000,
        },
        {
          title: "太陽能",
          size: 1360000,
        },
        {
          title: "偷鄰居的",
          size: 1000000,
        },
      ],
    }).subscribe(setPowerSourceData);
    return () => sub.unsubscribe();
  }, []);
  return <PowerDashboard powerSourceData={powerSourceData} />;
}
