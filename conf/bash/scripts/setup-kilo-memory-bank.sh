#!/bin/sh

set -e

# create directory .kilocode/rules/memory-bank/ in current project.
echo "Creating directory .kilocode/rules/memory-bank/..."
mkdir -p .kilocode/rules/memory-bank/

# create a file in .kilocode/rules/memory-bank/brief.md
if [ ! -f .kilocode/rules/memory-bank/brief.md ]; then
  echo "This project provides a streamlined memory bank setup for Kilo Code, enabling efficient rule management and documentation. Key features include automated directory creation, instruction download, and clear structure. Built with shell scripting for portability and ease of use." > .kilocode/rules/memory-bank/brief.md
else
  touch .kilocode/rules/memory-bank/brief.md
fi

# create a file .kilocode/rules/memory-bank-instructions.md with the content from `https://kilocode.ai/docs/downloads/memory-bank.md`
echo "Downloading memory bank instructions..."
curl -sL https://kilocode.ai/docs/downloads/memory-bank.md -o .kilocode/rules/memory-bank-instructions.md

# echo "Ask Kilo Code to \"initialize memory bank\""
echo ""
echo "Setup complete. \nAsk Kilo Code to \"initialize memory bank\""
