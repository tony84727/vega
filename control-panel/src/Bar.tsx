import { IBarProps } from "./IBarProps";
import { LinearProgress } from "@material-ui/core";
import { makeStyles } from "@material-ui/core/styles";

const useStyles = makeStyles({
  colorPrimary: {
    backgroundColor: ({ highContrast }: IBarProps) =>
      highContrast ? "#bbbbbb" : undefined,
  },
  barColorPrimary: {
    backgroundColor: ({ barColor }: IBarProps) => barColor,
  },
});

export default function Bar(props: IBarProps) {
  const { highContrast, barColor, ...rest } = props;
  const styles = useStyles(props)
  return <LinearProgress classes={styles} {...rest} />;
}
