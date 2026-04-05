#!/bin/bash

sudo systemctl restart blog.service
sudo systemctl reload nginx
echo 'Restart blog complete'
