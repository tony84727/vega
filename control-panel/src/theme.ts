import { createMuiTheme } from "@material-ui/core";

export default createMuiTheme({
  palette: {
    primary: {
      main: "#ffff00",
      contrastText: "#fff",
    },
    secondary: {
      main: "#bdbec0",
      contrastText: "#fff",
    },
    error: {
      main: "#e74d12",
    },
    background: {
      default: "#36373d",
      paper: "#4a4a4a",
    },
    text: {
      primary: "#fff",
      secondary: "#fff",
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
