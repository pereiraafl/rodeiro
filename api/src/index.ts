import express, { Request, Response } from 'express';
import dotenv from "dotenv";

import { Rodeiro } from "./schema";

dotenv.config();

import { connect } from 'mongoose';

const connectionString = process.env.DB || "";

const app = express();

const port: number = 3000;

app.get('/', async (req: Request, res: Response) => {

  const rodeiro = new Rodeiro({
    temp_init: 55,
    temp_final: 78,
    cycle: 1
  });

  const newUser = await rodeiro.save();
  res.status(201).json(newUser);

});

app.listen(port, async () => {
  await connect(connectionString);
  console.log(`Server is running on http://localhost:${port}`);
});
