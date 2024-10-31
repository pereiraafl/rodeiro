import express, { Request, Response } from 'express';
import dotenv from "dotenv";

import { HighestLowestSchema, ContinuousSchema } from "./schema";
import { IRodeiroHighestLowest, IRodeiroContinuous } from './models';
import { model, connect } from "mongoose";

import { Server } from 'socket.io';
import { createServer } from 'http';
const app = express();
app.use(express.json())
app.use(express.urlencoded({ extended: true }));
dotenv.config();
const connectionString = process.env.DB || "";


const server = createServer(app);
const io = new Server(server);


const port: number = 3000;


let ContinuousRodeiro: any;
let HighestLowestRodeiro: any;

let arduinoSocketCommunication = false;
let arduinoShouldSendOn = false;
let arduinoShouldSendOff = false;

app.get("/test", async (_: Request, res: Response) => {
  res.json({ "server": "working fine" });
})

// Probably a good idea to get some params from the request in order to create the new collection in the future.
app.get("/new", async (_: Request, res: Response) => {
  const date = new Date().toLocaleString().replace(" ", "").replace(",", "@").slice(0, -3);
  ContinuousRodeiro = model<IRodeiroContinuous>(`Continuous${date}`, ContinuousSchema);
  HighestLowestRodeiro = model<IRodeiroHighestLowest>(`HighestLowest${date}`, HighestLowestSchema);
  res.json({ "server": "working fine" });
})

app.post('/continuous', async (req: Request, res: Response) => {
  try {
    const rodeiro_body: IRodeiroContinuous = req.body;
    const rodeiro = new ContinuousRodeiro(rodeiro_body);
    await rodeiro.save();
    res.status(201).json();
  } catch (error) {
    console.log(error);
    res.status(400).json({ "error": "failed to parse 'rodeiro' struct" });
  }
});

app.post('/highestlowest', async (req: Request, res: Response) => {
  try {
    const rodeiro_body: IRodeiroHighestLowest = req.body;
    const rodeiro = new HighestLowestRodeiro(rodeiro_body);
    await rodeiro.save();
    res.status(201).json();
  } catch (error) {
    console.log(error);
    res.status(400).json({ "error": "failed to parse 'rodeiro' struct" });
  }
});

app.get('/continuous', async (_: Request, res: Response) => {
  try {
    const data = await ContinuousRodeiro.find();
    res.json(data);
  } catch (error) {
    res.status(500).json({ "error": "failed to get the users" });
  }
});


app.get('/highestlowest', async (_: Request, res: Response) => {
  try {
    const data = await HighestLowestRodeiro.find();
    res.json(data);
  } catch (error) {
    res.status(500).json({ "error": "failed to get the users" });
  }
});


app.get('/continuous/last', async (_: Request, res: Response) => {
  try {
    const data = await ContinuousRodeiro.findOne({}).sort({ _id: -1 });
    res.json(data);
  } catch (error) {
    res.status(500).json({ "error": "failed to get the users" });
  }
});


app.get('/highestlowest/last', async (_: Request, res: Response) => {
  try {
    const data = await HighestLowestRodeiro.findOne({}).sort({ _id: -1 });
    res.json(data);
  } catch (error) {
    res.status(500).json({ "error": "failed to get the users" });
  }
});

app.get('/arduino/on', async (_: Request, res: Response) => {
  try {
    arduinoSocketCommunication = true;
    arduinoShouldSendOn = true;
    res.json({ "message": "obrigado por ligar o arduino. Volte sempre" });
  } catch (error) {
    res.status(500).json({ "error": "server failed" });
  }
});

app.get('/arduino/off', async (_: Request, res: Response) => {
  try {
    arduinoSocketCommunication = true;
    arduinoShouldSendOff = true;
    res.json({ "message": "obrigado por desligar o arduino. Volte sempre" });
  } catch (error) {
    res.status(500).json({ "error": "server failed" });
  }
});

io.on('connection', (socket: any) => {

  console.log("Someone just connected on sockets. ID: ", socket.id);

  setInterval(() => {
    if (arduinoSocketCommunication) {
      if (arduinoShouldSendOn) {
        socket.emit('send', { message: 'Arduino deveria ligar' });
        arduinoShouldSendOn = false;
      }
      if (arduinoShouldSendOff) {
        socket.emit('send', { message: 'Arduino deveria desligar' });
        arduinoShouldSendOff = false;
      }
      arduinoSocketCommunication = false;
    }
  }, 1000);
});

server.listen(port, async () => {
  await connect(connectionString);
  console.log(`Server is running on http://localhost:${port}`);
});
