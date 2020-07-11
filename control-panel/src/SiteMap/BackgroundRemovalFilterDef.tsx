import { IBackgroundRemovalFilterDefProps } from "./IBackgroundRemovalFilterDefProps";

export default function BackgroundRemovalFilterDef({
  backgroundColor,
}: IBackgroundRemovalFilterDefProps) {
  return (
    <filter x="0" y="0" width="1" height="1" id="removebackground">
      <feFlood flood-color={backgroundColor} />
      <feComposite in="SourceGraphic" />
    </filter>
  );
}
