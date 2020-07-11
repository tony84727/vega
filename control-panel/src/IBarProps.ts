import { LinearProgressProps } from "@material-ui/core";

export interface IBarProps extends LinearProgressProps {
  highContrast?: boolean;
  barColor?: string;
}
