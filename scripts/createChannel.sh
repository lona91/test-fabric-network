#!/bin/bash
export CHANNEL_NAME="$1"
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/rms.com/oem/orderer/msp/tlscacerts/tlsca.oem.rms.com-cert.pem

if [ ! -d "channel-artifacts" ]; then
	mkdir channel-artifacts
fi



createChannelTx() {

	set -x
	bin/configtxgen -configPath configtx -profile NewChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
	set +x

}

createAnchorPeer() {
  for orgmsp in oemMSP insuranceMSP clientMSP; do
    echo "#######    Generating anchor peer update transaction for ${orgmsp}  ##########"
    set -x
    bin/configtxgen -configPath configtx -profile NewChannel -outputAnchorPeersUpdate ./channel-artifacts/${orgmsp}anchors.tx -channelID $CHANNEL_NAME -asOrg ${orgmsp}
    set +x
  done
}

export FABRIC_CFG_PATH=${PWD}/configtx

createChannelTx
createAnchorPeer


export FABRIC_CFG_PATH=${PWD}/config/
echo "${FABRIC_CFG_PATH}"
echo 'peer create channel'

export CORE_PEER_LOCALMSPID="oemMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/rms.com/oem/peer0/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/rms.com/oem/users/Admin@oem.rms.com/msp
export CORE_PEER_ADDRESS=localhost:7051
bin/peer channel create -o localhost:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.oem.rms.com -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt



export CORE_PEER_LOCALMSPID="oemMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/rms.com/oem/peer0/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/rms.com/oem/users/Admin@oem.rms.com/msp
export CORE_PEER_ADDRESS=localhost:7051
bin/peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

export CORE_PEER_LOCALMSPID="clientMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/rms.com/client/peer0/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/rms.com/client/users/Admin@client.rms.com/msp
export CORE_PEER_ADDRESS=localhost:8051
bin/peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

export CORE_PEER_LOCALMSPID="insuranceMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/rms.com/insurance/peer0/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/rms.com/insurance/users/Admin@insurance.rms.com/msp
export CORE_PEER_ADDRESS=localhost:9051
bin/peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block

export CORE_PEER_LOCALMSPID="oemMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/rms.com/oem/peer0/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/rms.com/oem/users/Admin@oem.rms.com/msp
export CORE_PEER_ADDRESS=localhost:7051
bin/peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.oem.rms.com -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

export CORE_PEER_LOCALMSPID="clientMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/rms.com/client/peer0/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/rms.com/client/users/Admin@client.rms.com/msp
export CORE_PEER_ADDRESS=localhost:8051
bin/peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.oem.rms.com -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

export CORE_PEER_LOCALMSPID="insuranceMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/rms.com/insurance/peer0/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/rms.com/insurance/users/Admin@insurance.rms.com/msp
export CORE_PEER_ADDRESS=localhost:9051
bin/peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.oem.rms.com -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
