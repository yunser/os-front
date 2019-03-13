#!/bin/bash
npm run build
ssh root@120.78.177.9 "mkdir /usr/local/nginx/os"
scp -r ./dist/* root@120.78.177.9:/usr/local/nginx/os
