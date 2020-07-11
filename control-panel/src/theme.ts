import { createMuiTheme } from "@material-ui/core";

export default createMuiTheme({
  palette: {
    primary: {
      main: "#52daf6",
    },
    secondary: {
      main: "#bdbec0",
    },
    error: {
      main: "#e74d12",
    },
    background: {
      default: "#161916",
      paper: "#3b3b3b",
    },
  },
  overrides: {
    MuiCssBaseline: {
      "@global": {
        "html, body, #__next": {
          height: "100%",
        },
      },
    },
  },
});
