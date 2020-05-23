#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        scripts/ccp/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        scripts/ccp/ccp-template.yaml | sed -e $'s/\\\\n/\\\n        /g'
}

ORG=oem
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/rms.com/oem/tlsca/tlsca.oem.rms.com-cert.pem
CAPEM=organizations/rms.com/oem/ca/ca.oem.rms.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/rms.com/oem/connection-oem.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/rms.com/oem/connection-oem.yaml

ORG=client
P0PORT=8051
CAPORT=8054
PEERPEM=organizations/rms.com/client/tlsca/tlsca.client.rms.com-cert.pem
CAPEM=organizations/rms.com/client/ca/ca.client.rms.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/rms.com/client/connection-client.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/rms.com/client/connection-client.yaml

ORG=insurance
P0PORT=9051
CAPORT=9054
PEERPEM=organizations/rms.com/insurance/tlsca/tlsca.insurance.rms.com-cert.pem
CAPEM=organizations/rms.com/insurance/ca/ca.insurance.rms.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/rms.com/insurance/connection-insurance.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/rms.com/insurance/connection-insurance.yaml
