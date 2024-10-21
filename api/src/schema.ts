import { Schema, model } from "mongoose";
import { IRodeiroHighestLowest, IRodeiroContinuous } from "./models";

export const HighestLowestSchema = new Schema<IRodeiroHighestLowest>({
  temp_init: { type: Number, required: true },
  temp_final: { type: Number, required: true },
  cycle: { type: Number, required: true },
});

export const ContinuousSchema = new Schema<IRodeiroContinuous>({
  current_temp: { type: Number, required: true },
  cycle: { type: Number, required: true },
});

