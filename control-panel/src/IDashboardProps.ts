import { SunburstPoint } from "react-vis";
import { Link, Site } from "./SiteMap";

export interface IDashboardProps {
  powerSourceData: SunburstPoint;
  sites: Site[];
  links: Link[];
}
