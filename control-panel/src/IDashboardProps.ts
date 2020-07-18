import { SunburstPoint } from "react-vis";
import ISiteMapData from "./SiteMap/ISiteMapData";
import { ISwitch } from "./SwitchBoard/ISwitch";
import { IDraconicReactorPanelProps } from "./Dashboard/IDraconicReactorPanelProps";

export interface IDashboardProps {
  powerSourceData: SunburstPoint;
  siteData: ISiteMapData;
  infraSwitches: ISwitch[];
  generatorSwitches: ISwitch[];
  draconicReactors: IDraconicReactorPanelProps[];
  messageLines: string[];
}
