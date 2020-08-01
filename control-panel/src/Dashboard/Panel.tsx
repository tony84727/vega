import React from "react";
import { IPanelProps } from "./IPanelProps";
import Card from "@material-ui/core/Card";
import { Typography } from "@material-ui/core";
import { makeStyles } from "@material-ui/core/styles";

const useStyles = makeStyles({
  content: {
    padding: "8px",
  },
});

export default function Panel({
  title,
  children,
}: IPanelProps): React.ReactElement {
  const styles = useStyles();
  return (
    <Card className={styles.content}>
      <Typography variant={"subtitle1"} color={"secondary"}>
        {title}
      </Typography>
      {children}
    </Card>
  );
}
