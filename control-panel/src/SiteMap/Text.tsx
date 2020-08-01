import React, { useMemo } from "react";
import { ITextProps } from "./ITextProps";

export default function Text({
  children,
  ...rest
}: ITextProps): React.ReactElement {
  const id = useMemo(() => `site-text-${children}`, [children]);
  return (
    <>
      <use xlinkHref={`#${id}`} filter="url(#removebackground)" />
      <text id={id} textAnchor={"middle"} {...rest}>
        {children}
      </text>
    </>
  );
}
