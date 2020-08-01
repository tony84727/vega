import React, { useCallback, useState } from "react";
import {
  FormControlLabel,
  Switch as MuiSwitch,
  Typography,
} from "@material-ui/core";
import { ISwitchProps } from "./ISwitchProps";

export default function Switch({
  switchData,
}: ISwitchProps): React.ReactElement {
  const [checked, setChecked] = useState(false);
  const onChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => setChecked(e.target.checked),
    []
  );
  return (
    <FormControlLabel
      control={
        <MuiSwitch color={"primary"} checked={checked} onChange={onChange} />
      }
      label={
        <Typography color={checked ? "primary" : "secondary"}>
          {switchData.name}
        </Typography>
      }
    />
  );
}
