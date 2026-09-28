import os
import sys
import mimetypes
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

# Ensure correct MIME types for Flutter Web
mimetypes.init()
mimetypes.add_type('application/wasm', '.wasm')
mimetypes.add_type('application/javascript', '.js')
mimetypes.add_type('application/json', '.json')
mimetypes.add_type('image/png', '.png')
mimetypes.add_type('text/html', '.html')

WEB_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), 'mobile_app', 'build', 'web'))

class FlutterHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        # Prevent aggressive browser caching of broken debug bundles
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        # SPA routing: if path doesn't exist as a file, serve index.html
        path = self.translate_path(self.path)
        if not os.path.exists(path) or os.path.isdir(path):
            index_path = os.path.join(WEB_DIR, 'index.html')
            if os.path.exists(index_path) and not self.path.startswith('/assets/'):
                self.path = '/index.html'
        return super().do_GET()

if __name__ == '__main__':
    port = 3000
    host = '0.0.0.0'
    print(f"Starting multi-threaded Flutter Web server on http://{host}:{port}")
    print(f"Serving files from: {WEB_DIR}")
    server = ThreadingHTTPServer((host, port), FlutterHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
