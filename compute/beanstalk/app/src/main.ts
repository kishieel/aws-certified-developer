import dotenv from 'dotenv';
import express from 'express';
import {z} from "zod";

dotenv.config();

const schema = z.object({
    HOST: z.string(),
    PORT: z.coerce.number().int().positive()
});

const config = schema.parse(process.env);

const app = express();
const host: string = config.HOST;
const port: number = config.PORT;

app.get('/', (req, res) => res.send('Hello World!'));
app.get('/health', (req, res) => res.send('OK'));
app.listen(port, host, () => console.log(`Server listening on http://${host}:${port}`));
