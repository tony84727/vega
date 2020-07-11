import { SVGAttributes } from "react";

export interface ITextProps extends SVGAttributes<SVGTextElement> {
  children: string;
}
