import { Link, Site } from "./SiteMap";

export const sites: Site[] = [
  {
    name: "核能反應爐",
    coordinate: [160, 40],
  },
  {
    name: "自動工廠",
    coordinate: [230, 10],
  },
  {
    name: "Vega實驗室",
    coordinate: [250, -149],
  },
  {
    name: "玄學研究所",
    coordinate: [98, -1],
  },
  {
    name: "太空中心",
    coordinate: [77, -100],
  },
];

export const links: Link[] = [
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
