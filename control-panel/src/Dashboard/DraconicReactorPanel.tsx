import { IDraconicReactorPanelProps } from "./IDraconicReactorPanelProps";
import DraconicReactorStatus from "../DraconicReactorStatus/DraconicReactorStatus";
import Panel from "./Panel";

export default function DraconicReactorPanel({
  name,
  ...rest
}: IDraconicReactorPanelProps) {
  return (
    <Panel title={name}>
      <DraconicReactorStatus {...rest} />
    </Panel>
  );
}
