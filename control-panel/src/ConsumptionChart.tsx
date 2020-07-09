import { AreaSeries, XAxis, XYPlot, YAxis } from "react-vis";

interface SiteData {
  name: string;
  series: [Date, number][];
}
interface IConsumptionChart {
  siteData: SiteData[];
}
export default function ConsumptionChart({ siteData }: IConsumptionChart) {
  return (
    <XYPlot height={300} width={300}>
      <XAxis />
      <YAxis />
      {siteData.map((site) => (
        <AreaSeries key={site.name} data={site.series} />
      ))}
    </XYPlot>
  );
}
