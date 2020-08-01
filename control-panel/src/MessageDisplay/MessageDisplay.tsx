import React, { useCallback } from "react";
import { IMessageDisplay } from "../IMessageDisplay";
import { FixedSizeList } from "react-window";
import { IMessageRowProps } from "./IMessageRowProps";
import { ListItem, ListItemText } from "@material-ui/core";
import { makeStyles } from "@material-ui/styles";

const useListItemStyles = makeStyles({
  root: {
    padding: 0,
  },
});

const useListItemTextStyles = makeStyles({
  root: {
    margin: 0,
  },
});

export default function MessageDisplay({
  lines,
}: IMessageDisplay): React.ReactElement {
  const listItemStyles = useListItemStyles();
  const listItemTextStyles = useListItemTextStyles();
  const MessageRow = useCallback(
    ({ index }: IMessageRowProps) => (
      <ListItem classes={listItemStyles}>
        <ListItemText classes={listItemTextStyles} primary={lines[index]} />
      </ListItem>
    ),
    [lines, listItemStyles, listItemTextStyles]
  );
  return (
    <FixedSizeList
      itemSize={24}
      itemCount={lines.length}
      width={300}
      height={300}
    >
      {MessageRow}
    </FixedSizeList>
  );
}
