import { createMuiTheme } from "@material-ui/core";

export default createMuiTheme({
  palette: {
    primary: {
      main: "#1ef6c5",
    },
    secondary: {
      main: "#63c4e2",
    },
    error: {
      main: "#e74d12",
    },
    background: {
      default: "#002e57",
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
