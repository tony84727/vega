import React, { useEffect, useState } from "react";
import { Observable, of } from "rxjs";
import { SunburstPoint } from "react-vis";
import { Dashboard } from "./Dashboard/Dashboard";
import { powerLinks, sites } from "./siteMapMockData";
import { generatorSwitches, switches } from "./switchBoardMockData";
import { draconicReactors } from "./draconicReactorMockData";
import useDebuggingConsole from "./useDebuggingConsole";
import useWebsocket from "./useWebsocket";
import { map } from "rxjs/operators";

export default function MockDashboard() {
  const [powerSourceData, setPowerSourceData] = useState<SunburstPoint>({
    title: "root",
    size: 0,
    children: [],
  });
  useEffect(() => {
    const sub = of({
      title: "root",
      size: 0,
      children: [
        {
          title: "神龍反應堆",
          size: 1870000,
        },
        {
          title: "太陽能",
          size: 1360000,
        },
        {
          title: "偷鄰居的",
          size: 1000000,
        },
      ],
    }).subscribe(setPowerSourceData);
    return () => sub.unsubscribe();
  }, []);
  const { message$ } = useWebsocket("ws://localhost:8080/websocket");
  const [line$] = useState(() => message$.pipe(map((x) => x.data)));
  const lines = useDebuggingConsole(line$);
  return (
    <Dashboard
      powerSourceData={powerSourceData}
      siteData={{ sites, powerLinks }}
      infraSwitches={switches}
      generatorSwitches={generatorSwitches}
      draconicReactors={draconicReactors}
      messageLines={lines}
    />
  );
}
