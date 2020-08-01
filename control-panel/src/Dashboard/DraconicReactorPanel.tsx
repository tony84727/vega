import React from "react";
import { IDraconicReactorPanelProps } from "./IDraconicReactorPanelProps";
import DraconicReactorStatus from "../DraconicReactorStatus/DraconicReactorStatus";
import Panel from "./Panel";

export default function DraconicReactorPanel({
  name,
  ...rest
}: IDraconicReactorPanelProps): React.ReactElement {
  return (
    <Panel title={name}>
      <DraconicReactorStatus {...rest} />
    </Panel>
  );
}
