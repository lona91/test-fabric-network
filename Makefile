/usr/bin/peer:
	./scripts/installBinaries.sh

./config: /bin
	sudo cp -r /usr/share/fabric/config ./config

.ONESHELL:
startNetwork: /usr/bin/peer ./config
	cd test-network
	./network.sh up -s couchdb -cai 1.4.6 -i 2.0.0 -ca -l javascript -verbose