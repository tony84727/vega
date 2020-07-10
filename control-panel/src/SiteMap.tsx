import { Card } from "@material-ui/core";
import { useEffect, useMemo, useRef, useState } from "react";

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

interface ISvgTextProps {
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

function SvgText({ children }: ISvgTextProps) {
  const id = useMemo(() => `site-text-${children}`, [children]);
  return (
    <>
      <use xlinkHref={`#${id}`} filter="url(#removebackground)" />
      <text id={id} textAnchor={"middle"}>
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
          <line
            key={l.key}
            x1={l.from[0] + width / 2}
            y1={l.from[1] + height / 2}
            x2={l.to[0] + width / 2}
            y2={l.to[1] + height / 2}
            stroke={siteColor}
            strokeWidth={2}
          />
        ))}
      </svg>
    </Card>
  );
}
