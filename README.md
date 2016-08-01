# docker-bitcore_insight_dash

dockerized bitcore insight-api for dash - alpha version

# requirements

    2GB ram to build
    1GB ram to run

# build

    git clone https://github.com/moocowmoo/docker-bitcore_insight_dash
    cd docker-bitcore_insight_dash
    sudo docker build -t dashpay/bitcore_insight:1.1 .
    # go have a sandwich, takes 30+ minutes
    # verify build completed successfully, then
    sudo docker create -p 3001:3001 --name bitcore_insight dashpay/bitcore_insight:1.1

# start/stop

    sudo docker start bitcore_insight
    sudo docker stop bitcore_insight
