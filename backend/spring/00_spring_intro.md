# Spring - Spring Boot Introduction

### How to install Spring Boot CLI
```
sudo apt install unzip zip
curl -s https://get.sdkman.io | bash
source "/home/username/.sdkman/bin/sdkman-init.sh"=
sdk install springboot
spring version
```

### Create a new project using CLI
```
spring help init
spring init --list
spring init -d=web,jpa --build-gradle my-project
spring init --dependencies=web,data-jpa my-project
spring init --dependencies=web --build=gradle --java-version=1.8 my-new-app
spring init --build=gradle --java-version=1.8 --dependencies=websocket --packaging=war sample-app.zip
```

### Run the project using maven
```
mvn spring-boot:run 
```

### Create a jar with maven and run it
```
mvn clean package
java -jar target/some-project-0.0.1-SNAPSHOT.jar
```







### Run the project using gradle
```
./gradlew bootRun
```

### Create a jar with gradle and run it
```
./gradew build
java -jar build/libs/my-new-app-0.0.1-SNAPSHOT.jar
```





### src/main/java/com/oreilly/boot/Application.java
package com.oreilly.boot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@EnableAutoConfiguration
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @RequestMapping("/")
    public String home() {
        return "Homepage";
    }
}


### Override the default configuration
### /src/main/resources/application.properties
```
server.port=8080
server.servlet.context-path=/demo
type=Framework
name=Spring Boot ${type}
```

### Or via yaml
### /src/main/resources/application.yml
```
server:
  port: 8989
  servlet:
    context-path: /demo
type: Framework
name: Spring Boot ${type}
```


### SpringBootApplication annotation includes:
- Configuration
- EnableAutoConfiguration
- ComponentScan

### Spring Initializr
- start.spring.io

