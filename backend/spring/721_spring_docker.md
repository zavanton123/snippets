# Spring Docker and docker compose
### messages/Dockerfile
```
FROM openjdk:11

WORKDIR /usr/src/messages
COPY build/libs/messages-0.0.1.jar .

CMD ["java", "-jar", "messages-0.0.1.jar"]

```




### products/Dockerfile
```
FROM openjdk:11

WORKDIR "/usr/src/products"
COPY build/libs/products-0.0.1.jar .

CMD ["java", "-jar", "products-0.0.1.jar"]
```








### docker-compose.yml
```
version: '3'
services:
  messages:
    container_name: messages
    image: zavanton/messages:latest
    build:
      context: ./messages
      dockerfile: Dockerfile
    ports:
      - 9000:9000
  products:
    container_name: products
    image: zavanton/products:latest
    build:
      context: ./products
      dockerfile: Dockerfile
    ports:
      - 9001:9001
networks:
  default:
    external:
      name: localdev

```






### docker-compose-scale.yml
```
# docker-compose --file docker-compose-scale.yml \
#  up --build -d \
#  --scale messages=3 \
#  --scale products=2
version: '3'
services:
  messages:
    # note: container name must not be set!
    image: zavanton/messages:latest
    build:
      context: ./messages
      dockerfile: Dockerfile
    # note: setup the port range:
    ports:
      - 9000-9499:9000
  products:
    # note: container name must not be set!
    image: zavanton/products:latest
    build:
      context: ./products
      dockerfile: Dockerfile
    # note: setup the port range:
    ports:
      - 9500-9990:9001
networks:
  default:
    external:
      name: localdev

```
