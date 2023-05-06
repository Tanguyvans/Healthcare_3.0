createCertificateForHospital() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p crypto-config-ca/peerOrganizations/hospital.network.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/

  
  ../../../bin/fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca.hospital.network.com --tls.certfiles ${PWD}/fabric-ca/hospital/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-hospital-network-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-hospital-network-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-hospital-network-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-hospital-network-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
  ../../../bin/fabric-ca-client register --caname ca.hospital.network.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/hospital/tls-cert.pem

  echo
  echo "Register peer1"
  echo
  ../../../bin/fabric-ca-client register --caname ca.hospital.network.com --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/hospital/tls-cert.pem

  echo
  echo "Register user"
  echo
  ../../../bin/fabric-ca-client register --caname ca.hospital.network.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/hospital/tls-cert.pem

  echo
  echo "Register the org admin"
  echo
  ../../../bin/fabric-ca-client register --caname ca.hospital.network.com --id.name hospitaladmin --id.secret hospitaladminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/hospital/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/hospital.network.com/peers

  # -----------------------------------------------------------------------------------
  #  Peer 0
  mkdir -p crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com

  echo
  echo "## Generate the peer0 msp"
  echo
  ../../../bin/fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.hospital.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/msp --csr.hosts peer0.hospital.network.com --tls.certfiles ${PWD}/fabric-ca/hospital/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  ../../../bin/fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.hospital.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/tls --enrollment.profile tls --csr.hosts peer0.hospital.network.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/hospital/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/tlsca
  cp ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/tlsca/tlsca.hospital.network.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/ca
  cp ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer0.hospital.network.com/msp/cacerts/* ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/ca/ca.hospital.network.com-cert.pem

  # ------------------------------------------------------------------------------------------------

  # Peer1

  mkdir -p crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer1.hospital.network.com

  echo
  echo "## Generate the peer1 msp"
  echo
  ../../../bin/fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca.hospital.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer1.hospital.network.com/msp --csr.hosts peer1.hospital.network.com --tls.certfiles ${PWD}/fabric-ca/hospital/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer1.hospital.network.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
  ../../../bin/fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca.hospital.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer1.hospital.network.com/tls --enrollment.profile tls --csr.hosts peer1.hospital.network.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/hospital/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer1.hospital.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer1.hospital.network.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer1.hospital.network.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer1.hospital.network.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer1.hospital.network.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/peers/peer1.hospital.network.com/tls/server.key

  # --------------------------------------------------------------------------------------------------

  mkdir -p crypto-config-ca/peerOrganizations/hospital.network.com/users
  mkdir -p crypto-config-ca/peerOrganizations/hospital.network.com/users/User1@hospital.network.com

  echo
  echo "## Generate the user msp"
  echo
  ../../../bin/fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca.hospital.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/users/User1@hospital.network.com/msp --tls.certfiles ${PWD}/fabric-ca/hospital/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/hospital.network.com/users/Admin@hospital.network.com

  echo
  echo "## Generate the org admin msp"
  echo
  ../../../bin/fabric-ca-client enroll -u https://hospitaladmin:hospitaladminpw@localhost:7054 --caname ca.hospital.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/users/Admin@hospital.network.com/msp --tls.certfiles ${PWD}/fabric-ca/hospital/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/hospital.network.com/users/Admin@hospital.network.com/msp/config.yaml

}

createCertificateForCardiology() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p crypto-config-ca/peerOrganizations/cardiology.network.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/

  
  ../../../bin/fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca.cardiology.network.com --tls.certfiles ${PWD}/fabric-ca/cardiology/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-cardiology-network-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-cardiology-network-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-cardiology-network-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-cardiology-network-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
  ../../../bin/fabric-ca-client register --caname ca.cardiology.network.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/cardiology/tls-cert.pem

  echo
  echo "Register peer1"
  echo
  ../../../bin/fabric-ca-client register --caname ca.cardiology.network.com --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/cardiology/tls-cert.pem

  echo
  echo "Register user"
  echo
  ../../../bin/fabric-ca-client register --caname ca.cardiology.network.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/cardiology/tls-cert.pem

  echo
  echo "Register the org admin"
  echo
  ../../../bin/fabric-ca-client register --caname ca.cardiology.network.com --id.name cardiologyadmin --id.secret cardiologyadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/cardiology/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/cardiology.network.com/peers

  # -----------------------------------------------------------------------------------
  #  Peer 0
  mkdir -p crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com

  echo
  echo "## Generate the peer0 msp"
  echo
  ../../../bin/fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.cardiology.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/msp --csr.hosts peer0.cardiology.network.com --tls.certfiles ${PWD}/fabric-ca/cardiology/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  ../../../bin/fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.cardiology.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/tls --enrollment.profile tls --csr.hosts peer0.cardiology.network.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/cardiology/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/tlsca
  cp ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/tlsca/tlsca.cardiology.network.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/ca
  cp ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer0.cardiology.network.com/msp/cacerts/* ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/ca/ca.cardiology.network.com-cert.pem

  # ------------------------------------------------------------------------------------------------

  # Peer1

  mkdir -p crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer1.cardiology.network.com

  echo
  echo "## Generate the peer1 msp"
  echo
  ../../../bin/fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca.cardiology.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer1.cardiology.network.com/msp --csr.hosts peer1.cardiology.network.com --tls.certfiles ${PWD}/fabric-ca/cardiology/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer1.cardiology.network.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
  ../../../bin/fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca.cardiology.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer1.cardiology.network.com/tls --enrollment.profile tls --csr.hosts peer1.cardiology.network.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/cardiology/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer1.cardiology.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer1.cardiology.network.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer1.cardiology.network.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer1.cardiology.network.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer1.cardiology.network.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/peers/peer1.cardiology.network.com/tls/server.key

  # --------------------------------------------------------------------------------------------------

  mkdir -p crypto-config-ca/peerOrganizations/cardiology.network.com/users
  mkdir -p crypto-config-ca/peerOrganizations/cardiology.network.com/users/User1@cardiology.network.com

  echo
  echo "## Generate the user msp"
  echo
  ../../../bin/fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca.cardiology.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/users/User1@cardiology.network.com/msp --tls.certfiles ${PWD}/fabric-ca/cardiology/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/cardiology.network.com/users/Admin@cardiology.network.com

  echo
  echo "## Generate the org admin msp"
  echo
  ../../../bin/fabric-ca-client enroll -u https://cardiologyadmin:cardiologyadminpw@localhost:8054 --caname ca.cardiology.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/users/Admin@cardiology.network.com/msp --tls.certfiles ${PWD}/fabric-ca/cardiology/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/cardiology.network.com/users/Admin@cardiology.network.com/msp/config.yaml

}

createCertificateForGeneralServices() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p crypto-config-ca/peerOrganizations/generalservices.network.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/

  
  ../../../bin/fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca.generalservices.network.com --tls.certfiles ${PWD}/fabric-ca/generalservices/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-generalservices-network-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-generalservices-network-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-generalservices-network-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-generalservices-network-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
  ../../../bin/fabric-ca-client register --caname ca.generalservices.network.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/generalservices/tls-cert.pem

  echo
  echo "Register peer1"
  echo
  ../../../bin/fabric-ca-client register --caname ca.generalservices.network.com --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/generalservices/tls-cert.pem

  echo
  echo "Register user"
  echo
  ../../../bin/fabric-ca-client register --caname ca.generalservices.network.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/generalservices/tls-cert.pem

  echo
  echo "Register the org admin"
  echo
  ../../../bin/fabric-ca-client register --caname ca.generalservices.network.com --id.name generalservicesadmin --id.secret generalservicesadminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/generalservices/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/generalservices.network.com/peers

  # -----------------------------------------------------------------------------------
  #  Peer 0
  mkdir -p crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com

  echo
  echo "## Generate the peer0 msp"
  echo
  ../../../bin/fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca.generalservices.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/msp --csr.hosts peer0.generalservices.network.com --tls.certfiles ${PWD}/fabric-ca/generalservices/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  ../../../bin/fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca.generalservices.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/tls --enrollment.profile tls --csr.hosts peer0.generalservices.network.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/generalservices/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/tlsca
  cp ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/tlsca/tlsca.generalservices.network.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/ca
  cp ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer0.generalservices.network.com/msp/cacerts/* ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/ca/ca.generalservices.network.com-cert.pem

  # ------------------------------------------------------------------------------------------------

  # Peer1

  mkdir -p crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer1.generalservices.network.com

  echo
  echo "## Generate the peer1 msp"
  echo
  ../../../bin/fabric-ca-client enroll -u https://peer1:peer1pw@localhost:9054 --caname ca.generalservices.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer1.generalservices.network.com/msp --csr.hosts peer1.generalservices.network.com --tls.certfiles ${PWD}/fabric-ca/generalservices/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer1.generalservices.network.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
  ../../../bin/fabric-ca-client enroll -u https://peer1:peer1pw@localhost:9054 --caname ca.generalservices.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer1.generalservices.network.com/tls --enrollment.profile tls --csr.hosts peer1.generalservices.network.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/generalservices/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer1.generalservices.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer1.generalservices.network.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer1.generalservices.network.com/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer1.generalservices.network.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer1.generalservices.network.com/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/peers/peer1.generalservices.network.com/tls/server.key

  # --------------------------------------------------------------------------------------------------

  mkdir -p crypto-config-ca/peerOrganizations/generalservices.network.com/users
  mkdir -p crypto-config-ca/peerOrganizations/generalservices.network.com/users/User1@generalservices.network.com

  echo
  echo "## Generate the user msp"
  echo
  ../../../bin/fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca.generalservices.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/users/User1@generalservices.network.com/msp --tls.certfiles ${PWD}/fabric-ca/generalservices/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/generalservices.network.com/users/Admin@generalservices.network.com

  echo
  echo "## Generate the org admin msp"
  echo
  ../../../bin/fabric-ca-client enroll -u https://generalservicesadmin:generalservicesadminpw@localhost:9054 --caname ca.generalservices.network.com -M ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/users/Admin@generalservices.network.com/msp --tls.certfiles ${PWD}/fabric-ca/generalservices/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/generalservices.network.com/users/Admin@generalservices.network.com/msp/config.yaml

}

createCertificateForOrderer() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p crypto-config-ca/ordererOrganizations/network.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/ordererOrganizations/network.com

   
  ../../../bin/fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca-orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/ordererOrganizations/network.com/msp/config.yaml

  echo
  echo "Register orderer"
  echo
   
  ../../../bin/fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer2"
  echo
   
  ../../../bin/fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer3"
  echo
   
  ../../../bin/fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register the orderer admin"
  echo
   
  ../../../bin/fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  mkdir -p crypto-config-ca/ordererOrganizations/network.com/orderers
  # mkdir -p crypto-config-ca/ordererOrganizations/network.com/orderers/network.com

  # ---------------------------------------------------------------------------
  #  Orderer

  mkdir -p crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  ../../../bin/fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com/msp --csr.hosts orderer.network.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  ../../../bin/fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com/tls --enrollment.profile tls --csr.hosts orderer.network.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com/msp/tlscacerts/tlsca.network.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/network.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/msp/tlscacerts/tlsca.network.com-cert.pem

  # -----------------------------------------------------------------------
  #  Orderer 2

  mkdir -p crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  ../../../bin/fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com/msp --csr.hosts orderer2.network.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  ../../../bin/fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com/tls --enrollment.profile tls --csr.hosts orderer2.network.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com/msp/tlscacerts/tlsca.network.com-cert.pem

  # mkdir ${PWD}/crypto-config-ca/ordererOrganizations/network.com/msp/tlscacerts
  # cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer2.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/msp/tlscacerts/tlsca.network.com-cert.pem

  # ---------------------------------------------------------------------------
  #  Orderer 3
  mkdir -p crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  ../../../bin/fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com/msp --csr.hosts orderer3.network.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  ../../../bin/fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com/tls --enrollment.profile tls --csr.hosts orderer3.network.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com/msp/tlscacerts/tlsca.network.com-cert.pem

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/network.com/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/orderers/orderer3.network.com/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/network.com/msp/tlscacerts/tlsca.network.com-cert.pem

  # ---------------------------------------------------------------------------

  mkdir -p crypto-config-ca/ordererOrganizations/network.com/users
  mkdir -p crypto-config-ca/ordererOrganizations/network.com/users/Admin@network.com

  echo
  echo "## Generate the admin msp"
  echo
   
  ../../../bin/fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:10054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/network.com/users/Admin@network.com/msp --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/network.com/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/network.com/users/Admin@network.com/msp/config.yaml

}

sudo rm -rf crypto-config-ca/*
createCertificateForHospital
createCertificateForCardiology
createCertificateForGeneralServices
createCertificateForOrderer

