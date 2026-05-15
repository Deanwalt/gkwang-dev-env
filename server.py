#!/usr/bin/env python3
import argparse
import os
from http.server import SimpleHTTPRequestHandler, HTTPServer

class TextViewHandler(SimpleHTTPRequestHandler):
    """
    将所有文件都按文本显示，除非是二进制（如图片、视频等）。
    这里简化处理：我们直接强制全部返回 text/plain。
    """
    extensions_map = {
        # 继承默认的 MIME 映射，同时覆盖常见代码文件
        '.html': 'text/html',
        '.htm': 'text/html',
        '.css': 'text/css',
        '.js': 'application/javascript',
        '.json': 'application/json',
        '.xml': 'application/xml',
        '.txt': 'text/plain',
        '.py': 'text/plain',
        '.c': 'text/plain',
        '.h': 'text/plain',
        '.cpp': 'text/plain',
        '.hpp': 'text/plain',
        '.sh': 'text/plain',
        '.bash': 'text/plain',
        '.md': 'text/markdown',
        '.rst': 'text/x-rst',
        '.yaml': 'text/plain',
        '.yml': 'text/plain',
        '.toml': 'text/plain',
        '.ini': 'text/plain',
        '.cfg': 'text/plain',
        '.conf': 'text/plain',
        '.patch': 'text/plain',
        '.diff': 'text/plain',
        # 图片等二进制保持默认
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.gif': 'image/gif',
        '.svg': 'image/svg+xml',
        '.ico': 'image/x-icon',
        '.woff2': 'font/woff2',
    }

    def guess_type(self, path):
        """根据扩展名返回对应的 MIME，如果未知就返回 text/plain"""
        base, ext = os.path.splitext(path)
        if ext.lower() in self.extensions_map:
            return self.extensions_map[ext.lower()]
        else:
            # 关键：对于未知后缀，一律当作文本返回
            return 'text/plain; charset=utf-8'

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('port', type=int, default=10025, nargs='?')
    parser.add_argument('--directory', '-d', default=os.getcwd())
    parser.add_argument('--bind', '-b', default='0.0.0.0')
    args = parser.parse_args()

    os.chdir(args.directory)
    server = HTTPServer((args.bind, args.port), TextViewHandler)
    server.serve_forever()

if __name__ == '__main__':
    main()
