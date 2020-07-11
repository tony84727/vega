import { SunburstPoint } from "react-vis";
import ISiteMapData from "./SiteMap/ISiteMapData";

export interface IDashboardProps {
  powerSourceData: SunburstPoint;
  siteData: ISiteMapData;
}
