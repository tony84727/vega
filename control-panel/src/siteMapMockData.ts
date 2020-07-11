import { ISite } from "./SiteMap/ISite";
import { IPowerLink } from "./SiteMap/IPowerLink";

export const sites: ISite[] = [
  {
    name: "核能反應爐",
    coordinate: [50, 40],
  },
  {
    name: "自動工廠",
    coordinate: [-130, 200],
  },
  {
    name: "Vega實驗室",
    coordinate: [150, -149],
  },
  {
    name: "玄學研究所",
    coordinate: [-98, -1],
  },
  {
    name: "太空中心",
    coordinate: [0, -140],
  },
];

export const powerLinks: IPowerLink[] = [
  {
    flow: 100000,
    from: 0,
    to: 1,
  },
  {
    flow: 8000,
    from: 0,
    to: 2,
  },
  {
    flow: 256,
    from: 0,
    to: 3,
  },
  {
    flow: 10000,
    from: 0,
    to: 4,
  },
];