import React, { useEffect } from "react";
import { AppProps } from "next/app";
import { CssBaseline, ThemeProvider } from "@material-ui/core";
import theme from "../src/theme";

export default function App({
  Component,
  pageProps,
}: AppProps): React.ReactElement {
  useEffect(() => {
    const jssStyles = document.querySelector("#jss-server-side");
    if (jssStyles) {
      jssStyles.parentElement.removeChild(jssStyles);
    }
  }, []);
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Component {...pageProps} />
    </ThemeProvider>
  );
}
