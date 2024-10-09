#!/bin/bash

# 禁用IPv6 ULA 前缀
sed -i 's/^[^#].*option ula/#&/' /etc/config/network

exit 0
