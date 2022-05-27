import { Router } from "express";
import * as fs from 'fs';

const router = Router();

const readFileController = router.get("/", (_, res) => {
  try {
    fs.readFile("/azurefiles/test.txt", "utf8", (err, data) => {
      if (err) {
        console.error(err);
        return;
      }
      res.json({ message: data });
    });
  } catch (error) {
    console.log("An error has occurred: ", error);
  }
});

export default readFileController;
