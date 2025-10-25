#!/bin/bash

sui client ptb \
    --move-call $PACKAGE_ID::tamashi::set_name @$TAMASHI_ID "'$NAME'" @0x6 \
    --gas-budget 100000000 \
    --json
