import express, { json, urlencoded } from "express";

// Controllers
import homeController from "./controllers/homeController.js";
import readFileController from "./controllers/readFileController.js";

const app = express();
const port = process.env.PORT || 3000;

app.use(json());
app.use(
  urlencoded({
    extended: true,
  })
);

app.use(homeController);
app.use("/api/file/read", readFileController);

app.listen(port, () => console.log(`Server listening on: ${port}`));
