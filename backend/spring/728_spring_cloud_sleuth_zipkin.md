# Spring Cloud - microservices with Sleuth and Zipkin




### How to run Zipkin server via docker compose?
```
docker-compose up --build -d
docker-compose ps
docker-compose down
```










### ./docker-compose.yml
version: '3'
services:
  zipkin-server:
    image: openzipkin/zipkin
    ports:
      - 9411:9411
networks:
  default:
    external:
      name: localdev










## FIRST SERVICE
### app/build.gradle.kts
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

extra["springCloudVersion"] = "2020.0.4"

dependencies {
	// Kotlin
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    // Spring
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("org.springframework.cloud:spring-cloud-starter-feign:1.4.7.RELEASE")
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
    // Sleuth and Zipkin
	implementation("org.springframework.cloud:spring-cloud-starter-sleuth")
	implementation("org.springframework.cloud:spring-cloud-starter-zipkin:2.2.8.RELEASE")
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










### app/src/main/resources/application.yml
server:
  port: 9999
spring:
  application:
    name: first-service
  # setup zipkin
  zipkin:
    base-url: http://localhost:9411
    sender:
      type: web
  # setup sleuth
  sleuth:
    sampler:
      probability: 1










### app/src/main/kotlin/ru/zavanton/app/demo/SleuthApp.kt
package ru.zavanton.app.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.openfeign.EnableFeignClients

@SpringBootApplication
@EnableFeignClients
class SleuthApp

fun main(args: Array<String>) {
	runApplication<SleuthApp>(*args)
}










### app/src/main/kotlin/ru/zavanton/app/demo/controller/SleuthController.kt
package ru.zavanton.app.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.app.demo.client.DemoClient

@RestController
class SleuthController(
    private val demoClient: DemoClient,
) {
    private val log = LoggerFactory.getLogger(SleuthController::class.java)

    @GetMapping("")
    fun helloSleuth(): String {
        log.info("zavanton - hello sleuth")
        return "success"
    }

    @GetMapping("info")
    fun otherServiceRequestDemo(): String {
        log.info("zavanton - otherServiceRequestDemo")
        return demoClient.fetchInfo()
    }
}










### app/src/main/kotlin/ru/zavanton/app/demo/client/DemoClient.kt
package ru.zavanton.app.demo.client

import org.springframework.cloud.openfeign.FeignClient
import org.springframework.web.bind.annotation.GetMapping

@FeignClient(name="hello", url = "http://localhost:7878")
interface DemoClient {

    @GetMapping("/")
    fun fetchInfo(): String
}










## SECOND SERVICE
### info/build.gradle.kts
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

extra["springCloudVersion"] = "2020.0.4"

dependencies {
	// Kotlin
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
    // Spring
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("org.springframework.cloud:spring-cloud-starter-feign:1.4.7.RELEASE")
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	// Sleuth and Zipkin
	implementation("org.springframework.cloud:spring-cloud-starter-zipkin:2.2.8.RELEASE")
	implementation("org.springframework.cloud:spring-cloud-starter-sleuth")
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










### info/src/main/resources/application.yml
server:
  port: 7878
spring:
  application:
    name: second-service
  # setup zipkin
  zipkin:
    base-url: http://localhost:9411
    sender:
      type: web
  # setup sleuth
  sleuth:
    sampler:
      probability: 1










### info/src/main/kotlin/ru/zavanton/app/info/InfoApp.kt
package ru.zavanton.app.info

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.openfeign.EnableFeignClients

@SpringBootApplication
@EnableFeignClients
class InfoApp

fun main(args: Array<String>) {
	runApplication<InfoApp>(*args)
}










### info/src/main/kotlin/ru/zavanton/app/info/controller/InfoController.kt
package ru.zavanton.app.info.controller

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.app.info.client.InfoClient

@RestController
class InfoController(
    private val infoClient: InfoClient,
) {
    private val log = LoggerFactory.getLogger(InfoController::class.java)

    @GetMapping("")
    fun info(): String {
        log.info("zavanton - inside InfoController getting info...")
        return infoClient.fetchDetails()
    }
}










### info/src/main/kotlin/ru/zavanton/app/info/client/InfoClient.kt
package ru.zavanton.app.info.client

import org.springframework.cloud.openfeign.FeignClient
import org.springframework.web.bind.annotation.GetMapping

@FeignClient(name = "info", url = "http://localhost:8989")
interface InfoClient {

    @GetMapping("/")
    fun fetchDetails(): String
}
















## THIRD SERVICE
### details/build.gradle.kts
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

extra["springCloudVersion"] = "2020.0.4"

dependencies {
	// Kotlin
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
    // Spring
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
	// Sleuth and Zipkin
	implementation("org.springframework.cloud:spring-cloud-starter-zipkin:2.2.8.RELEASE")
	implementation("org.springframework.cloud:spring-cloud-starter-sleuth")
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










### details/src/main/resources/application.yml
server:
  port: 8989
spring:
  application:
    name: third-service
  # setup zipkin
  zipkin:
    base-url: http://localhost:9411
    sender:
      type: web
  # setup sleuth
  sleuth:
    sampler:
      probability: 1









### details/src/main/kotlin/ru/zavanton/app/details/DetailsApp.kt
package ru.zavanton.app.details

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class DetailsApp

fun main(args: Array<String>) {
	runApplication<DetailsApp>(*args)
}










### details/src/main/kotlin/ru/zavanton/app/details/controller/DetailsController.kt
package ru.zavanton.app.details.controller

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class DetailsController {

    private val log = LoggerFactory.getLogger(DetailsController::class.java)

    @GetMapping("")
    fun details(): String {
        log.info("zavanton - fetching details...")
        return "details"
    }
}
