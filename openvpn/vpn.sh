#!/bin/bash

sudo openvpn \
        --daemon \
        --cd /etc/openvpn \
        --config ubuntu.ovpn \
        --auth-user-pass /etc/openvpn/passwd \
        --log-append ~/openvpn.log
