import express, { Request, Response } from 'express';
import dotenv from "dotenv";

import { RodeiroSchema } from "./schema";
import { IRodeiro } from './models';
import { model } from "mongoose";


dotenv.config();

import { connect } from 'mongoose';

const connectionString = process.env.DB || "";

const app = express();

app.use(express.json())

app.use(express.urlencoded({ extended: true }));

const port: number = 3000;

let Rodeiro: any;

app.get("/", async (req: Request, res: Response) => {
  res.json({ "server": "working fine" });
})

// Probably a good idea to get some params from the request in order to create the new collection in the future.
app.get("/new", async (req: Request, res: Response) => {
  const date = new Date().toLocaleString().replace(" ", "").replace(",", "@").slice(0, -3);
  Rodeiro = model<IRodeiro>(`Planilha${date}`, RodeiroSchema);
  res.json({ "server": "working fine" });
})

app.post('/send', async (req: Request, res: Response) => {
  try {
    const rodeiro_body: IRodeiro = req.body;
    const rodeiro = new Rodeiro(rodeiro_body);
    await rodeiro.save();
    res.status(201);
  } catch (error) {
    console.log(error);
    res.status(400).json({ "error": "failed to parse 'rodeiro' struct" });
  }
});

app.get('/get', async (req: Request, res: Response) => {
  try {
    const data = await Rodeiro.find();
    res.json(data);
  } catch (error) {
    res.status(500).json({ "error": "failed to get the users" });
  }
});

app.listen(port, async () => {
  await connect(connectionString);
  console.log(`Server is running on http://localhost:${port}`);
});
