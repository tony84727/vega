import { AppProps } from "next/app";
import { ReactElement, useEffect } from "react";

export default function App({ Component, pageProps }: AppProps): ReactElement {
  useEffect(() => {
    const jssStyles = document.querySelector("#jss-server-side");
    if (jssStyles) {
      jssStyles.parentElement.removeChild(jssStyles);
    }
  }, []);
  return <Component {...pageProps} />;
}
