const express = require("express");
const cors = require("cors");
const fs = require("fs");
const path = require("path");
const app = express();
const port = 3000;

app.use(cors());
app.get("/:directory(*)", (req, res) => {
  const directory = req.params.directory;
  const files = getFilesRecursive(path.join("./static-files", directory));
  res.json(files);
});

function formatSize(sizeInBytes) {
    const KB = 1024;
    const MB = KB * 1024;
    if (sizeInBytes < KB) {
      return (sizeInBytes / KB).toFixed(1) + " kB";
    } else if (sizeInBytes < MB) {
      const sizeInKB = (sizeInBytes / KB).toFixed(2);
      return sizeInKB + " kB";
    } else {
      const sizeInMB = (sizeInBytes / MB).toFixed(2);
      return sizeInMB + " mB";
    }
  }

function getFilesRecursive(dir) {
  const files = fs.readdirSync(dir);
  return files.map((file) => {
    const filePath = path.join(dir, file);
    const stats = fs.statSync(filePath);
    const isDirectory = stats.isDirectory();
    const size = isDirectory ? null : formatSize(stats.size);
    const creationDate = isDirectory ? null : stats.mtime.toISOString();
    return {
      name: file,
      isDirectory,
      path: filePath,
      size,
      creationDate,
    };
  });
}

app.listen(port, () => {
  console.log(`Server is listening at http://localhost:${port}`);
});
