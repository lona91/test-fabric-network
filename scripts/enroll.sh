#!/bin/bash

function createOEMOrg {
  mkdir -p ${PWD}/organizations/rms.com/oem/ca

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/rms.com/oem/

  # Enroll admin
  
  bin/fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-oem --tls.certfiles ${PWD}/organizations/rms.com/oem/ca/tls-cert.pem
  

  mkdir -p ${PWD}/organizations/rms.com/oem/msp

  echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
      Certificate: cacerts/localhost-7054-ca-oem.pem
      OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
      Certificate: cacerts/localhost-7054-ca-oem.pem
      OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
      Certificate: cacerts/localhost-7054-ca-oem.pem
      OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
      Certificate: cacerts/localhost-7054-ca-oem.pem
      OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/rms.com/oem/msp/config.yaml

  
  # Register peer
  bin/fabric-ca-client register --caname ca-oem --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/rms.com/oem/ca/tls-cert.pem
  # Register user
  bin/fabric-ca-client register --caname ca-oem --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/rms.com/oem/ca/tls-cert.pem
  # Register order
  bin/fabric-ca-client register --caname ca-oem --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/rms.com/oem/ca/tls-cert.pem
  # Register org admin
  bin/fabric-ca-client register --caname ca-oem --id.name oemadmin --id.secret oemadminpw --id.type admin --tls.certfiles ${PWD}/organizations/rms.com/oem/ca/tls-cert.pem
  

  # Generate peer 0 msp and tls certificates
  mkdir -p ${PWD}/organizations/rms.com/oem/peer0
  
  bin/fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-oem -M ${PWD}/organizations/rms.com/oem/peer0/msp --csr.hosts peer0.oem.rms.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/rms.com/oem/ca/tls-cert.pem
  
  cp ${PWD}/organizations/rms.com/oem/msp/config.yaml ${PWD}/organizations/rms.com/oem/peer0/msp/config.yaml


  
  bin/fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-oem -M ${PWD}/organizations/rms.com/oem/peer0/tls --enrollment.profile tls --csr.hosts peer0.oem.rms.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/rms.com/oem/ca/tls-cert.pem
  
  cp ${PWD}/organizations/rms.com/oem/peer0/tls/tlscacerts/* ${PWD}/organizations/rms.com/oem/peer0/tls/ca.crt
  cp ${PWD}/organizations/rms.com/oem/peer0/tls/signcerts/* ${PWD}/organizations/rms.com/oem/peer0/tls/server.crt
  cp ${PWD}/organizations/rms.com/oem/peer0/tls/keystore/* ${PWD}/organizations/rms.com/oem/peer0/tls/server.key

  mkdir ${PWD}/organizations/rms.com/oem/msp/tlscacerts
  cp ${PWD}/organizations/rms.com/oem/peer0/tls/tlscacerts/*  ${PWD}/organizations/rms.com/oem/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/rms.com/oem/tlsca
  cp ${PWD}/organizations/rms.com/oem/peer0/tls/tlscacerts/* ${PWD}/organizations/rms.com/oem/tlsca/tlsca.oem.rms.com-cert.pem

  cp ${PWD}/organizations/rms.com/oem/peer0/msp/cacerts/* ${PWD}/organizations/rms.com/oem/ca/ca.oem.rms.com-cert.pem

  # Generate orderer msp and tls certificates
  mkdir -p ${PWD}/organizations/rms.com/oem/orderer/msp
  
  bin/fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7054 --caname ca-oem -M ${PWD}/organizations/rms.com/oem/orderer/msp --csr.hosts orderer.oem.rms.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/rms.com/oem/ca/tls-cert.pem
  
  cp ${PWD}/organizations/rms.com/oem/msp/config.yaml ${PWD}/organizations/rms.com/oem/orderer/msp/config.yaml

  bin/fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7054 --caname ca-oem -M ${PWD}/organizations/rms.com/oem/orderer/tls --enrollment.profile tls --csr.hosts orderer.oem.rms.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/rms.com/oem/ca/tls-cert.pem
  

  cp ${PWD}/organizations/rms.com/oem/orderer/tls/tlscacerts/* ${PWD}/organizations/rms.com/oem/orderer/tls/ca.crt
  cp ${PWD}/organizations/rms.com/oem/orderer/tls/signcerts/* ${PWD}/organizations/rms.com/oem/orderer/tls/server.crt
  cp ${PWD}/organizations/rms.com/oem/orderer/tls/keystore/* ${PWD}/organizations/rms.com/oem/orderer/tls/server.key

  mkdir ${PWD}/organizations/rms.com/oem/orderer/msp/tlscacerts
  cp ${PWD}/organizations/rms.com/oem/orderer/tls/tlscacerts/* ${PWD}/organizations/rms.com/oem/orderer/msp/tlscacerts/tlsca.oem.rms.com-cert.pem

  cp ${PWD}/organizations/rms.com/oem/orderer/tls/tlscacerts/* ${PWD}/organizations/rms.com/oem/msp/tlscacerts/tlsca.oem.rms.com-cert.pem

  # Generate user msp
  mkdir -p ${PWD}/organizations/rms.com/oem/users
  mkdir -p ${PWD}/organizations/rms.com/oem/users/User1@oem.rms.com

  
  bin/fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-oem -M ${PWD}/organizations/rms.com/oem/users/User1@oem.rms.com/msp --tls.certfiles ${PWD}/organizations/rms.com/oem/ca/tls-cert.pem
  


  # Generate admin msp
  mkdir -p ${PWD}/organizations/rms.com/oem/users/Admin@oem.rms.com

  
  bin/fabric-ca-client enroll -u https://oemadmin:oemadminpw@localhost:7054 --caname ca-oem -M ${PWD}/organizations/rms.com/oem/users/Admin@oem.rms.com/msp --tls.certfiles ${PWD}/organizations/rms.com/oem/ca/tls-cert.pem
  
  cp ${PWD}/organizations/rms.com/oem/msp/config.yaml ${PWD}/organizations/rms.com/oem/users/Admin@oem.rms.com/msp/config.yaml

}

function createClientOrg {
  mkdir -p ${PWD}/organizations/rms.com/client/ca

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/rms.com/client/

  # Enroll admin
  
  bin/fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-client --tls.certfiles ${PWD}/organizations/rms.com/client/ca/tls-cert.pem
  

  mkdir -p ${PWD}/organizations/rms.com/client/msp

  echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
      Certificate: cacerts/localhost-8054-ca-client.pem
      OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
      Certificate: cacerts/localhost-8054-ca-client.pem
      OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
      Certificate: cacerts/localhost-8054-ca-client.pem
      OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
      Certificate: cacerts/localhost-8054-ca-client.pem
      OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/rms.com/client/msp/config.yaml

  
  # Register peer
  bin/fabric-ca-client register --caname ca-client --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/rms.com/client/ca/tls-cert.pem
  # Register user
  bin/fabric-ca-client register --caname ca-client --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/rms.com/client/ca/tls-cert.pem
  # Register org admin
  bin/fabric-ca-client register --caname ca-client --id.name clientadmin --id.secret clientadminpw --id.type admin --tls.certfiles ${PWD}/organizations/rms.com/client/ca/tls-cert.pem
  
  # Generate peer 0 msp and tls certificates
  mkdir -p ${PWD}/organizations/rms.com/client/peer0
  
  bin/fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-client -M ${PWD}/organizations/rms.com/client/peer0/msp --csr.hosts peer0.client.rms.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/rms.com/client/ca/tls-cert.pem
  
  cp ${PWD}/organizations/rms.com/client/msp/config.yaml ${PWD}/organizations/rms.com/client/peer0/msp/config.yaml


  
  bin/fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-client -M ${PWD}/organizations/rms.com/client/peer0/tls --enrollment.profile tls --csr.hosts peer0.client.rms.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/rms.com/client/ca/tls-cert.pem
  
  cp ${PWD}/organizations/rms.com/client/peer0/tls/tlscacerts/* ${PWD}/organizations/rms.com/client/peer0/tls/ca.crt
  cp ${PWD}/organizations/rms.com/client/peer0/tls/signcerts/* ${PWD}/organizations/rms.com/client/peer0/tls/server.crt
  cp ${PWD}/organizations/rms.com/client/peer0/tls/keystore/* ${PWD}/organizations/rms.com/client/peer0/tls/server.key

  mkdir ${PWD}/organizations/rms.com/client/msp/tlscacerts
  cp ${PWD}/organizations/rms.com/client/peer0/tls/tlscacerts/*  ${PWD}/organizations/rms.com/client/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/rms.com/client/tlsca
  cp ${PWD}/organizations/rms.com/client/peer0/tls/tlscacerts/* ${PWD}/organizations/rms.com/client/tlsca/tlsca.client.rms.com-cert.pem

  cp ${PWD}/organizations/rms.com/client/peer0/msp/cacerts/* ${PWD}/organizations/rms.com/client/ca/ca.client.rms.com-cert.pem

    # Generate user msp
  mkdir -p ${PWD}/organizations/rms.com/client/users
  mkdir -p ${PWD}/organizations/rms.com/client/users/User1@client.rms.com

  
  bin/fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-client -M ${PWD}/organizations/rms.com/client/users/User1@client.rms.com/msp --tls.certfiles ${PWD}/organizations/rms.com/client/ca/tls-cert.pem
  


  # Generate admin msp
  mkdir -p ${PWD}/organizations/rms.com/client/users/Admin@client.rms.com

  
  bin/fabric-ca-client enroll -u https://clientadmin:clientadminpw@localhost:8054 --caname ca-client -M ${PWD}/organizations/rms.com/client/users/Admin@client.rms.com/msp --tls.certfiles ${PWD}/organizations/rms.com/client/ca/tls-cert.pem
  cp ${PWD}/organizations/rms.com/client/msp/config.yaml ${PWD}/organizations/rms.com/client/users/Admin@client.rms.com/msp/config.yaml

}

function createInsuranceOrg {
  mkdir -p ${PWD}/organizations/rms.com/insurance/ca

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/rms.com/insurance/

  # Enroll admin
  
  bin/fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-insurance --tls.certfiles ${PWD}/organizations/rms.com/insurance/ca/tls-cert.pem
  

  mkdir -p ${PWD}/organizations/rms.com/insurance/msp

  echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
      Certificate: cacerts/localhost-9054-ca-insurance.pem
      OrganizationalUnitIdentifier: insurance
    PeerOUIdentifier:
      Certificate: cacerts/localhost-9054-ca-insurance.pem
      OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
      Certificate: cacerts/localhost-9054-ca-insurance.pem
      OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
      Certificate: cacerts/localhost-9054-ca-insurance.pem
      OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/rms.com/insurance/msp/config.yaml

  
  # Register peer
  bin/fabric-ca-client register --caname ca-insurance --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/rms.com/insurance/ca/tls-cert.pem
  # Register user
  bin/fabric-ca-client register --caname ca-insurance --id.name user1 --id.secret user1pw --id.type insurance --tls.certfiles ${PWD}/organizations/rms.com/insurance/ca/tls-cert.pem
  # Register org admin
  bin/fabric-ca-client register --caname ca-insurance --id.name insuranceadmin --id.secret insuranceadminpw --id.type admin --tls.certfiles ${PWD}/organizations/rms.com/insurance/ca/tls-cert.pem
  
  # Generate peer 0 msp and tls certificates
  mkdir -p ${PWD}/organizations/rms.com/insurance/peer0
  
  bin/fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-insurance -M ${PWD}/organizations/rms.com/insurance/peer0/msp --csr.hosts peer0.insurance.rms.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/rms.com/insurance/ca/tls-cert.pem
  
  cp ${PWD}/organizations/rms.com/insurance/msp/config.yaml ${PWD}/organizations/rms.com/insurance/peer0/msp/config.yaml


  
  bin/fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-insurance -M ${PWD}/organizations/rms.com/insurance/peer0/tls --enrollment.profile tls --csr.hosts peer0.insurance.rms.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/rms.com/insurance/ca/tls-cert.pem
  
  cp ${PWD}/organizations/rms.com/insurance/peer0/tls/tlscacerts/* ${PWD}/organizations/rms.com/insurance/peer0/tls/ca.crt
  cp ${PWD}/organizations/rms.com/insurance/peer0/tls/signcerts/* ${PWD}/organizations/rms.com/insurance/peer0/tls/server.crt
  cp ${PWD}/organizations/rms.com/insurance/peer0/tls/keystore/* ${PWD}/organizations/rms.com/insurance/peer0/tls/server.key

  mkdir ${PWD}/organizations/rms.com/insurance/msp/tlscacerts
  cp ${PWD}/organizations/rms.com/insurance/peer0/tls/tlscacerts/*  ${PWD}/organizations/rms.com/insurance/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/rms.com/insurance/tlsca
  cp ${PWD}/organizations/rms.com/insurance/peer0/tls/tlscacerts/* ${PWD}/organizations/rms.com/insurance/tlsca/tlsca.insurance.rms.com-cert.pem

  cp ${PWD}/organizations/rms.com/insurance/peer0/msp/cacerts/* ${PWD}/organizations/rms.com/insurance/ca/ca.insurance.rms.com-cert.pem

    # Generate user msp
  mkdir -p ${PWD}/organizations/rms.com/insurance/users
  mkdir -p ${PWD}/organizations/rms.com/insurance/users/User1@insurance.rms.com

  
  bin/fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-insurance -M ${PWD}/organizations/rms.com/insurance/users/User1@insurance.rms.com/msp --tls.certfiles ${PWD}/organizations/rms.com/insurance/ca/tls-cert.pem
  


  # Generate admin msp
  mkdir -p ${PWD}/organizations/rms.com/insurance/users/Admin@insurance.rms.com

  
  bin/fabric-ca-client enroll -u https://insuranceadmin:insuranceadminpw@localhost:9054 --caname ca-insurance -M ${PWD}/organizations/rms.com/insurance/users/Admin@insurance.rms.com/msp --tls.certfiles ${PWD}/organizations/rms.com/insurance/ca/tls-cert.pem
  cp ${PWD}/organizations/rms.com/insurance/msp/config.yaml ${PWD}/organizations/rms.com/insurance/users/Admin@insurance.rms.com/msp/config.yaml

}