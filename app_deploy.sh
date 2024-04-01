#!/bin/bash

#Install Node in EC2 Instance
echo "Installing Node on EC2..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install --lts
node -e "console.log('Running Node.js ' + process.version)"

#Start App in EC2 instance
echo "Starting App in EC2..."
git clone https://github.com/CodeSagarOfficial/nodejs-demo.git
cd nodejs-demo
npm install
npm start