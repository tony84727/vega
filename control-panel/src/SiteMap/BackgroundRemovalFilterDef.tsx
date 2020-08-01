import React from "react";
import { IBackgroundRemovalFilterDefProps } from "./IBackgroundRemovalFilterDefProps";

export default function BackgroundRemovalFilterDef({
  backgroundColor,
}: IBackgroundRemovalFilterDefProps): React.ReactElement {
  return (
    <filter x="0" y="0" width="1" height="1" id="removebackground">
      <feFlood floodColor={backgroundColor} />
      <feComposite in="SourceGraphic" />
    </filter>
  );
}
