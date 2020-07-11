import {
  FormControlLabel,
  Switch as MuiSwitch,
  Typography,
} from "@material-ui/core";
import { ISwitchProps } from "./ISwitchProps";
import { useCallback, useState } from "react";

export default function Switch({ switchData }: ISwitchProps) {
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
