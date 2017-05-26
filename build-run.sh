#!/bin/bash
if [[ -f Screenfill.prg ]]; then
  echo "Delete Screenfill.prg."
  rm Screenfill.prg
else
  echo "Fillscreen.prg not found."
fi

# Build 
java -jar ../../KickAss.jar Screenfill.asm

# Run
if [[ -f Screenfill.prg ]]; then
  x64 Screenfill.prg
fi
