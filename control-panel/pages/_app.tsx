import { AppProps } from "next/app";
import { ReactElement, useEffect } from "react";
import { CssBaseline, ThemeProvider } from "@material-ui/core";
import theme from "../src/theme";

export default function App({ Component, pageProps }: AppProps): ReactElement {
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
