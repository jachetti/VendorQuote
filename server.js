const http = require('http');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const url = require('url');

const PORT = 80;

// Helper to serve static files
function serveFile(filePath, contentType, res) {
  fs.readFile(filePath, (err, content) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('404 Not Found');
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content);
    }
  });
}

// Helper to parse JSON body
function parseBody(req, callback) {
  let body = '';
  req.on('data', chunk => {
    body += chunk.toString();
  });
  req.on('end', () => {
    try {
      callback(null, JSON.parse(body));
    } catch (e) {
      callback(e, null);
    }
  });
}

// Create HTTP server
const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  // Route handling
  if (req.method === 'GET') {
    if (pathname === '/') {
      serveFile(path.join(__dirname, 'app/views/index.html'), 'text/html', res);
    } else if (pathname === '/healthz') {
      res.writeHead(200, { 'Content-Type': 'text/plain' });
      res.end('ok');
    } else if (pathname === '/quotes') {
      serveFile(path.join(__dirname, 'app/views/quotes.html'), 'text/html', res);
    } else if (pathname === '/approvals') {
      serveFile(path.join(__dirname, 'app/views/approvals.html'), 'text/html', res);
    } else if (pathname === '/support') {
      serveFile(path.join(__dirname, 'app/views/support.html'), 'text/html', res);
    } else if (pathname === '/styles.css') {
      serveFile(path.join(__dirname, 'app/public/styles.css'), 'text/css', res);
    } else {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('404 Not Found');
    }
  } else if (req.method === 'POST' && pathname === '/api/support/diag') {
    // INTENTIONALLY VULNERABLE ENDPOINT FOR TRAINING
    // This endpoint is deliberately insecure for educational purposes
    // DO NOT use this pattern in production code

    parseBody(req, (err, data) => {
      if (err || !data || !data.note) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Note field required' }));
        return;
      }

      // VULNERABILITY: Unsanitized command execution
      // This is intentionally unsafe for training purposes
      exec(data.note, (error, stdout, stderr) => {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        if (error) {
          res.end(JSON.stringify({
            status: 'error',
            output: stderr || error.message
          }));
        } else {
          res.end(JSON.stringify({
            status: 'success',
            output: stdout
          }));
        }
      });
    });
  } else {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('404 Not Found');
  }
});

// Start server
server.listen(PORT, '0.0.0.0', () => {
  console.log(`VendorQuote running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'production'}`);
});
