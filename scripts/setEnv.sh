#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/rms.com/oem/orderer/msp/tlscacerts/tlsca.oem.rms.com-cert.pem
export PEER0_OEM_CA=${PWD}/organizations/rms.com/oem/peer0/tls/ca.crt
export PEER0_CLIENT_CA=${PWD}/organizations/rms.com/client/peer0/tls/ca.crt
export PEER0_INSURANCE_CA=${PWD}/organizations/rms.com/insurance/peer0/tls/ca.crt

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  export CORE_PEER_LOCALMSPID="oemMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/rms.com/oem/orderer/msp/tlscacerts/tlsca.oem.rms.com-cert.pem
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/rms.com/oem/users/Admin@oem.rms.com
}

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG="oem"
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  echo "Using organization ${USING_ORG}"
  if [ $USING_ORG == "oemOrg" ]; then
    export CORE_PEER_LOCALMSPID="oemMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_OEM_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/rms.com/oem/users/Admin@oem.rms.com
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_ORG == "clientOrg" ]; then
    export CORE_PEER_LOCALMSPID="clientMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_CLIENT_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/rms.com/client/users/Admin@client.rms.com
    export CORE_PEER_ADDRESS=localhost:8051

  elif [ $USING_ORG == "insuranceOrg" ]; then
    export CORE_PEER_LOCALMSPID="insuranceMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_INSURANCE_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/rms.com/insurance/users/Admin@insurance.rms.com
    export CORE_PEER_ADDRESS=localhost:9051
  else
    echo "================== ERROR !!! ORG Unknown =================="
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {

  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.$1"
    ## Set peer adresses
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_$1_CA")
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    # shift by one to get to the next organization
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}