import * as fs from "node:fs/promises"

export const file = (path) => path

export const write_ = (file) => (content) => async () =>
  await fs.writeFile(file, content, { encoding: "utf8" })

export const read_ = (file) => async () =>
  await fs.readFile(file, { encoding: "utf8" })


