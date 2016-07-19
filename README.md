# dash-docker-bitcore_insight

dockerized bitcore insight - alpha version

# requirements

    2GB ram to build
    1GB ram to run

# build

    git clone https://github.com/moocowmoo/dash-docker-bitcore_insight
    cd dash-docker-bitcore_insight
    sudo docker build -t dash/bitcore_insight:1.0 .
    # go have a sandwich, takes 30+ minutes
    # verify build completed successfully, then
    sudo docker create -p 3001:3001 --name bitcore_insight dash/bitcore_insight:1.0

# start/stop

    sudo docker start bitcore_insight
    sudo docker stop bitcore_insight
