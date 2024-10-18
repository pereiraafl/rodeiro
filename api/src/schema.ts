import { Schema, model } from "mongoose";
import { IRodeiro } from "./models";

const rodeiroSchema = new Schema<IRodeiro>({
  temp_init: { type: Number, required: true },
  temp_final: { type: Number, required: true },
  cycle: { type: Number, required: true },
});

export const Rodeiro = model<IRodeiro>('Rodeiro', rodeiroSchema);

