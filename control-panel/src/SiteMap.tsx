import { Card } from "@material-ui/core";
import { SVGAttributes, useMemo } from "react";

export interface Site {
  coordinate: [number, number];
  name: string;
}

export interface Link {
  from: number;
  to: number;
  flow: number;
}

interface ISiteMapProps {
  sites: Site[];
  powerLinks?: Link[];
  width?: number;
  height?: number;
}

interface ISvgTextProps extends SVGAttributes<SVGTextElement> {
  background: string;
  children: string;
}

function BackgroundRemovalFilterDef({
  backgroundColor,
}: {
  backgroundColor: string;
}) {
  return (
    <filter x="0" y="0" width="1" height="1" id="removebackground">
      <feFlood flood-color={backgroundColor} />
      <feComposite in="SourceGraphic" />
    </filter>
  );
}

function SvgText({ children, ...rest }: ISvgTextProps) {
  const id = useMemo(() => `site-text-${children}`, [children]);
  return (
    <>
      <use xlinkHref={`#${id}`} filter="url(#removebackground)" />
      <text id={id} textAnchor={"middle"} {...rest}>
        {children}
      </text>
    </>
  );
}

function Site({ name, color }: { name: string; color: string }) {
  return (
    <>
      <circle r={15} stroke={color} fill={"transparent"} strokeWidth={2} />
      <circle r={10} />
      <g transform={"translate(0, 30)"}>
        <SvgText background={"#fff"}>{name}</SvgText>
      </g>
    </>
  );
}

interface ISiteMapLinkProps {
  from: [number, number];
  to: [number, number];
  flow: number;
  color: string;
}

function SiteMapLink({ from, to, color, flow }: ISiteMapLinkProps) {
  const middle = useMemo(() => [(from[0] + to[0]) / 2, (from[1] + to[1]) / 2], [
    from,
    to,
  ]);
  return (
    <>
      <line
        x1={from[0]}
        y1={from[1]}
        x2={to[0]}
        y2={to[1]}
        stroke={color}
        strokeWidth={2}
      />
      <SvgText background={"#fff"} x={middle[0]} y={middle[1]}>
        {flow.toString()} RF/t
      </SvgText>
    </>
  );
}

export default function SiteMap({
  sites,
  powerLinks,
  width = 600,
  height = 600,
}: ISiteMapProps) {
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
    <Card>
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
          <SiteMapLink
            key={`link-${l.from}-${l.to}`}
            color={siteColor}
            from={[l.from[0] + width / 2, l.from[1] + height / 2]}
            to={[l.to[0] + width / 2, l.to[1] + height / 2]}
            flow={l.flow}
          />
        ))}
      </svg>
    </Card>
  );
}
