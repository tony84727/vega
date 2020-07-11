import { useMemo } from "react";
import PowerLink from "./PowerLink";
import Site from "./Site";
import BackgroundRemovalFilterDef from "./BackgroundRemovalFilterDef";
import { ISiteMapProps } from "./ISiteMapProps";

export default function SiteMap({
  data,
  width = 600,
  height = 600,
}: ISiteMapProps) {
  const { sites, powerLinks } = data;
  const siteColor = "#fff749";
  const links = useMemo(
    () =>
      powerLinks.map((l) => ({
        key: `${l.from}->${l.to}`,
        from: sites[l.from].coordinate,
        to: sites[l.to].coordinate,
        flow: l.flow,
      })),
    [powerLinks, sites]
  );
  return (
    <svg width={width} height={height}>
      <BackgroundRemovalFilterDef backgroundColor={"#0075ff"} />
      {sites.map((s) => (
        <g
          fill={siteColor}
          key={s.name}
          transform={`translate(${s.coordinate[0] + width / 2}, ${
            s.coordinate[1] + height / 2
          })`}
        >
          <Site name={s.name} color={siteColor} />
        </g>
      ))}
      {links.map((l) => (
        <PowerLink
          key={`link-${l.from}-${l.to}`}
          color={siteColor}
          from={[l.from[0] + width / 2, l.from[1] + height / 2]}
          to={[l.to[0] + width / 2, l.to[1] + height / 2]}
          flow={l.flow}
        />
      ))}
    </svg>
  );
}
