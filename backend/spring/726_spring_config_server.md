# Spring Cloud Config Server - How to set config server that reads configs from private git repoisitory (or file system) and uses encryption?



### Run RabbitMQ via Docker

```
docker run -it --rm -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.9-management

```

### How to notify clients of config changes?
```
send POST request to
http://localhost:8090/actuator/busrefresh
```

### How to generate jks for encrypting/decrypting config properties?

```
keytool -genkeypair -alias shkolumKey -keyalg RSA \
  -dname "CN=Anton Zaviyalov,OU=API Development,O=Shkolum,L=Moscow,S=MO,C=RU" \
  -keypass some-pass-here -keystore shkolumKey.jks -storepass some-pass-here

keytool -importkeystore -srckeystore shkolumKey.jks -destkeystore shkolumKey.jks -deststoretype pkcs12

```

### How to encrypt/decrypt properties?
```
POST + some body
http://localhost:8090/encrypt

POST + some body
http://localhost:8090/decrypt
```

### How to set encrypted property in application.properties?
### example:
```
custom.title={cipher}AQBaTv9Sc/dg2XP9r80YgUhLKZsqMB/8hOLrs3cyFiuHWdm8lJnuY4DgF48dFg4/XgDyg0pU4nnjRVg708mUWFyByPucrnKLhXCNEMPU7Zp4xuWNg8e7bXKCaPPzxK5gc6hJc/4NLPvFzL4kY6/UnWwVO43uX7yXK51ByWk4wbEPwg7XioBP6VBpfClEywPtmpsEmKqTGmKviiKvBB4LvcfRjDjRqUOhlm32xfhwiq8ntQNDEGlXyeYspyEUe3WwJ1SZoOwMOmO3Eycxm5U9Dcc37OcEAE9wW0jJ14hV4RN77OgzuSVvDAfs/GSuTyhC2tqHQms0/07UfowltjYN5NkNIh4nirhl7Hqv0zR7m93Bf3+oUDtuAOf4QgC7UqaWsmLd6qC4XM+/M3dmvwAaMZ/B
```
### or application.yml
```
custom:
  title: '{cipher}AQAmQHaRgN3WecRHHOsLsXLhnp5F4qiWDlEvHFKGH/n8MK2HQfOWGOl3vWXc0w4lPn1YOfa/6trSCCQQpekelrMFtklpCJo2jcXFC/DqTEOfjT95JC1GHUZEkU6ASp3wHgH+FPi/u9bExxTJS7+mu86sbKfebiA9tPTRq75R9lw3BXh4U/qoH1a/wsgeh1zjNdHS17Mm7ZEKdAZxrTqV5M20Qn6yuWbU/yMs2AkpjjFKzqbmLyaP1LkoE3qxQw5A2E8SwAPpaLg52JLyon8q2608kgqGH72+Lm/f3uDP56f+nz5VaGanQt87y1cGESmlItk+V+Dd+hN1eCYt2OQAqudmgRFLrnqdkBZQ0hH3Gln4D0tmyrsKgTaQzVzOLiZ6/Yg='

```


















## Config server
### config/build.gradle.kts
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.5"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.31"
	kotlin("plugin.spring") version "1.5.31"
}

group = "ru.zavanton.app"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_1_8

repositories {
	mavenCentral()
}

extra["springCloudVersion"] = "2020.0.3"

dependencies {
	// Kotlin
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
    // Spring
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	implementation("org.springframework.boot:spring-boot-starter-actuator")
	implementation("org.springframework.cloud:spring-cloud-config-server")
	implementation("org.springframework.cloud:spring-cloud-starter-bus-amqp")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
}

dependencyManagement {
	imports {
		mavenBom("org.springframework.cloud:spring-cloud-dependencies:${property("springCloudVersion")}")
	}
}

tasks.withType<KotlinCompile> {
	kotlinOptions {
		freeCompilerArgs = listOf("-Xjsr305=strict")
		jvmTarget = "1.8"
	}
}

tasks.withType<Test> {
	useJUnitPlatform()
}










### config/src/main/resources/application.yml
spring:
  application:
    name: config-service
  cloud:
    config:
      server:
        # 'git' profile is for getting configs from private git repository
        git:
          uri: https://bitbucket.org/chattyspot/config-demo
          username: zavanton@yandex.ru
          password: 134MY_life
          clone-on-start: true
        # 'native' profile is for getting configs from the local file storage
        native:
          search-locations: file://${user.home}/Desktop/config2
  # enable 'git' or 'native' profile
  profiles:
    active: native
  # rabbitmq is used to notify clients of config changes
  rabbitmq:
    host: localhost
    port: 5672
    username: guest
    password: guest
server:
  port: 8090
# setup actuator
management:
  endpoints:
    web:
      exposure:
        include: '*'
  endpoint:
    health:
      show-details: always
    # /actuator/busrefresh is used to notify clients of config changes
    busrefresh:
      enabled: true
# setup encryption of properties
encrypt:
  key-store:
    alias: demokey
    location: file://${user.home}/Desktop/demokey.jks
    password: 123456789










### config/src/main/kotlin/ru/zavanton/app/config/ConfigApp.kt
package ru.zavanton.app.config

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.config.server.EnableConfigServer

@SpringBootApplication
// Note: this enables the config server
@EnableConfigServer
class ConfigApp

fun main(args: Array<String>) {
	runApplication<ConfigApp>(*args)
}










## Course Service (client to config server)
plugins {
	id("org.springframework.boot") version "2.5.5"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.31"
	kotlin("plugin.spring") version "1.5.31"
}

group = "ru.zavanton.app"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_1_8

repositories {
	mavenCentral()
}

extra["springCloudVersion"] = "2020.0.3"

dependencies {
	// Kotlin
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
    // Spring
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("org.springframework.cloud:spring-cloud-starter-config")
	implementation("org.springframework.cloud:spring-cloud-starter-bus-amqp")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
    // Jackson
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
}

dependencyManagement {
	imports {
		mavenBom("org.springframework.cloud:spring-cloud-dependencies:${property("springCloudVersion")}")
	}
}

tasks.withType<KotlinCompile> {
	kotlinOptions {
		freeCompilerArgs = listOf("-Xjsr305=strict")
		jvmTarget = "1.8"
	}
}

tasks.withType<Test> {
	useJUnitPlatform()
}










### course/src/main/resources/bootstrap.yml
spring:
  cloud:
    config:
      enabled: true
      uri: http://localhost:8090
      name: config-service










### course/src/main/resources/application.yml
spring:
  application:
    name: course-service
  # setup connection to config server
  config:
    import: optional:configserver:http://localhost:8090
  # lister to rabbitmq for config changes from the config server
  rabbitmq:
    host: localhost
    port: 5672
    username: guest
    password: guest
server:
  port: 8989

# local custom property (it has lower priority compared to config server properties)
custom:
  title: Local Course Title










### course/src/main/kotlin/ru/zavanton/app/course/CourseApp.kt
package ru.zavanton.app.course

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class CourseApp

fun main(args: Array<String>) {
	runApplication<CourseApp>(*args)
}










### course/src/main/kotlin/ru/zavanton/app/course/controller/CourseController.kt
package ru.zavanton.app.course.controller

import org.springframework.core.env.Environment
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class CourseController(
    private val env: Environment,
) {

    @GetMapping("")
    fun info(): String {
        return env.getProperty("custom.title") ?: "default title"
    }
}

