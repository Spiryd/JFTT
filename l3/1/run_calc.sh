docker stop bison
docker rm bison
docker build . -t bison 
docker run --name bison -d -i -t bison /bin/sh
docker exec -it bison sh
