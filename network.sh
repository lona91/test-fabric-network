#!/bin/bash

function printHelp() {
  echo "Usage: "
  echo "  network.sh [command]"
  echo "    [command]:"
  echo "      - 'up' - bring up fabric cas, orderer and peer nodes. No channel is created"
}

function installBinaries() {
  read -p "Do you wish to install fabric binaries? [y/N]";
  if [[ "${REPLY}" == "Y" || "${REPLY}" == "y" ]]; then
    mkdir /tmp/fabric
    curl -sSL https://bit.ly/2ysbOFE -o /tmp/fabric/install.sh
    chmod a+x /tmp/fabric/install.sh
    /tmp/fabric/install.sh -d -s 
    rm -rf /tmp/fabric
  else
    exit 1
  fi
}

function checkPrereqs() {
  if [[ ! -d './bin' || ! -d "./config" ]]; then
    echo "ERROR! Binary fabric files missing"
    installBinaries
  fi

  DOCKER=$(which docker)
  if [ -z $DOCKER ]; then
    echo "ERROR! Docker missing"
    echo "Visit https://docs.docker.com/engine/install/ to discover how to install"
    exit
  fi


  DOCKERCOMPOSE=$(which docker-compose)
  if [ -z $DOCKERCOMPOSE ]; then
    echo "ERROR! Docker-compose missing"
    echo "Visit https://docs.docker.com/compose/install/ to discover how to install"
  fi
}

function createOrgs() {
  mkdir organizations/rms.com
  mkdir -p organizations/rms.com/oem/ca
  mkdir -p organizations/rms.com/insurance/ca
  mkdir -p organizations/rms.com/client/ca

  docker-compose -f docker/docker-compose-ca.yaml up -d

  sleep 2

  . scripts/enroll.sh
  echo '****************************************'
  echo '*  Enrolling OEM users, peers, orderer *'
  echo '****************************************'
  sleep 1
  createOEMOrg

  echo '****************************************'
  echo '*  Enrolling Client users, peers       *'
  echo '****************************************'
  sleep 1
  createClientOrg

  echo '****************************************'
  echo '*  Enrolling Insurance users, peers    *'
  echo '****************************************'
  sleep 1
  createInsuranceOrg

  . ./scripts/ccp/ccp-generator.sh
}

createConsortium() {
  mkdir organizations/blocks
  bin/configtxgen -configPath configtx -profile CustomProfile -channelID system-channel -outputBlock organizations/blocks/genesis.block
}

function networkUp() {
  checkPrereqs

  if [ ! -d "organizations" ]; then
    mkdir organizations
    createOrgs
    createConsortium
  fi

  docker-compose -f docker/docker-compose-network.yaml -f docker/docker-compose-couch.yaml up -d
}

function networkDestroy() {
  docker-compose -f docker/docker-compose-ca.yaml stop
  docker-compose  -f docker/docker-compose-couch.yaml -f docker/docker-compose-network.yaml stop 
  docker-compose -f docker/docker-compose-ca.yaml rm -f
  docker-compose  -f docker/docker-compose-couch.yaml -f docker/docker-compose-network.yaml rm -f 
  sudo rm -rf organizations
}


function createChannel() {
  CHANNEL_NAME=$1
  if [ -z $CHANNEL_NAME ]; then
    CHANNEL_NAME="custom-channel"
  fi
  scripts/createChannel.sh $CHANNEL_NAME
}


MODE=$1

if [ "${MODE}" == "up" ]; then
  networkUp
elif [ "${MODE}" == "destroy" ]; then
  networkDestroy
elif [ "${MODE}" == "attachExplorer" ]; then
  docker-compose -f docker/docker-compose-explorer.yaml up -d
else
  printHelp
  exit 1
fi