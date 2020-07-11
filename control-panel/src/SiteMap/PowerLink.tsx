import { useMemo } from "react";
import { IPowerLinkProps } from "./IPowerLinkProps";
import Text from "./Text";

export default function PowerLink({ from, to, color, flow }: IPowerLinkProps) {
  const middle = useMemo(() => [(from[0] + to[0]) / 2, (from[1] + to[1]) / 2], [
    from,
    to,
  ]);
  return (
    <>
      <line
        x1={from[0]}
        y1={from[1]}
        x2={to[0]}
        y2={to[1]}
        stroke={color}
        strokeWidth={2}
      />
      <Text x={middle[0]} y={middle[1]}>
        {flow.toString()} RF/t
      </Text>
    </>
  );
}
