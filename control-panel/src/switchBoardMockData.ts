import { ISwitch } from "./SwitchBoard/ISwitch";

export const switches: ISwitch[] = [
  "Site 1 總線",
  "Site 2 總線",
  "Site 3 總線",
  "Site 4 總線",
  "煉油廠 1號線",
  "煉油廠 2號線",
].map((name) => ({ name }));

export const generatorSwitches: ISwitch[] = [
  "生質柴油發電1號機",
  "生質柴油發電2號機",
  "生質柴油發電3號機",
  "生質柴油發電4號機",
  "生質柴油發電5號機",
  "核1 1號機",
  "核1 2號機",
  "核1 3號機",
  "核1 4號機",
  "神龍反應堆 Alpha",
  "神龍反應堆 Beta",
  "神龍反應堆 Charlie",
  "神龍反應堆 Delta",
].map((name) => ({ name }));
