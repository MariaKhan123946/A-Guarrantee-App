// Load the required modules
const http = require('http');
const formidable = require('formidable');
const fs = require('fs');
const path = require('path');

// Define the hostname and port
const hostname = '127.0.0.1';
const port = 3000;

// Create the HTTP server
const server = http.createServer((req, res) => {
  if (req.method.toLowerCase() === 'post') {
    // Handle file upload
    const form = new formidable.IncomingForm();
    form.uploadDir = path.join(__dirname, 'uploads'); // Set the upload directory

    form.parse(req, (err, fields, files) => {
      if (err) {
        res.statusCode = 500;
        res.end('Error occurred during file upload');
        return;
      }

      // Rename the uploaded file to its original name
      const oldPath = files.file.path;
      const newPath = path.join(form.uploadDir, files.file.name);

      fs.rename(oldPath, newPath, (err) => {
        if (err) {
          res.statusCode = 500;
          res.end('Error occurred while saving the file');
          return;
        }

        // Respond with success
        res.statusCode = 200;
        res.setHeader('Content-Type', 'text/plain');
        res.end('File uploaded successfully');
      });
    });
  } else {
    // For other requests, respond with a simple message
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello, World!\n');
  }
});

// Start the server and listen on the defined hostname and port
server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});

