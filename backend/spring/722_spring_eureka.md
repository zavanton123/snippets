# Spring - How to register services with Spring Cloud Eureka (querying with Spring Cloud Feign and RestTemplate)


# EUREKA CLIENT 1
### eureka-client/build.gradle.kts
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.4"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.21"
	kotlin("plugin.spring") version "1.5.21"
}

group = "ru.zavanton"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_1_8

repositories {
	mavenCentral()
}

extra["springCloudVersion"] = "2020.0.3"

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	implementation("org.springframework.cloud:spring-cloud-starter-netflix-eureka-client")
	developmentOnly("org.springframework.boot:spring-boot-devtools")
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











### eureka-client/src/main/resources/application.yml
spring:
  application:
    name: spring-cloud-eureka-client
server:
  port: 0
eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_URI:http://localhost:8761/eureka}
  instance:
    prefer-ip-address: true










### eureka-client/src/main/kotlin/ru/zavanton/client/DemoApplication.kt
package ru.zavanton.client

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.netflix.eureka.EnableEurekaClient

@SpringBootApplication
@EnableEurekaClient
class DemoApplication

fun main(args: Array<String>) {
	runApplication<DemoApplication>(*args)
}










### eureka-client/src/main/kotlin/ru/zavanton/client/controller/EurekaClientController.kt
package ru.zavanton.client.controller

import com.netflix.discovery.EurekaClient
import org.springframework.beans.factory.annotation.Value
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class EurekaClientController(
    private val eurekaClient: EurekaClient
) {

    @Value("\${spring.application.name}")
    private lateinit var appName: String

    @GetMapping("/greeting")
    fun greeting(): String {
        return "Hello world from ${eurekaClient.getApplication(appName).name}"
    }
}













# EUREKA SERVER
### eureka-server/build.gradle.kts
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.4"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.21"
	kotlin("plugin.spring") version "1.5.21"
}

group = "ru.zavanton"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_1_8

repositories {
	mavenCentral()
}

extra["springCloudVersion"] = "2020.0.3"

dependencies {
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	implementation("org.springframework.cloud:spring-cloud-starter-netflix-eureka-server")
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










### eureka-server/src/main/resources/application.yml
server:
  port: 8761
eureka:
  client:
    fetch-registry: false
    register-with-eureka: false










### eureka-server/src/main/kotlin/ru/zavanton/server/DemoApplication.kt
package ru.zavanton.server

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer

@SpringBootApplication
@EnableEurekaServer
class DemoApplication

fun main(args: Array<String>) {
	runApplication<DemoApplication>(*args)
}




















# EUREKA CLIENT 2 (FEIGN AND REST TEMPLATE CLIENT)
### myapp/build.gradle.kts
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.4"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.21"
	kotlin("plugin.spring") version "1.5.21"
}

group = "ru.zavanton"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_1_8

repositories {
	mavenCentral()
}

extra["springCloudVersion"] = "2020.0.3"

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-thymeleaf")
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	implementation("org.springframework.cloud:spring-cloud-starter-netflix-eureka-client")
	implementation("org.springframework.cloud:spring-cloud-starter-openfeign")
	developmentOnly("org.springframework.boot:spring-boot-devtools")
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










### myapp/src/main/resources/application.yml
spring:
  application:
    name: spring-cloud-eureka-feign-client
server:
  port: 8989
eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_URI:http://localhost:8761/eureka}











### myapp/src/main/resources/templates/greeting-view.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Greeting</title>
</head>
<body>
<h1>Greeting</h1>
<p th:text="${greeting}"></p>
</body>
</html>










### myapp/src/main/kotlin/ru/zavanton/myapp/DemoApplication.kt
package ru.zavanton.myapp

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.netflix.eureka.EnableEurekaClient
import org.springframework.cloud.openfeign.EnableFeignClients

@SpringBootApplication
@EnableFeignClients
@EnableEurekaClient
class DemoApplication

fun main(args: Array<String>) {
	runApplication<DemoApplication>(*args)
}










### myapp/src/main/kotlin/ru/zavanton/myapp/config/RestTemplateConfig.kt
package ru.zavanton.myapp.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.client.RestTemplate

@Configuration
class RestTemplateConfig {

    @Bean
    fun restTemplate(): RestTemplate {
        return RestTemplate()
    }
}










### myapp/src/main/kotlin/ru/zavanton/myapp/controller/AppController.kt
package ru.zavanton.myapp.controller

import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import ru.zavanton.myapp.client.GreetingClient

@Controller
class AppController(
    private val greetingClient: GreetingClient
) {

    @GetMapping("/get-greeting")
    fun greeting(model: Model): String {
        model.addAttribute("greeting", greetingClient.greeting())
        return "greeting-view"
    }

}










### myapp/src/main/kotlin/ru/zavanton/myapp/controller/MyController.kt
package ru.zavanton.myapp.controller

import com.netflix.discovery.EurekaClient
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.client.RestTemplate

@RestController
class MyController(
    private val eurekaClient: EurekaClient,
    private val restTemplate: RestTemplate,
) {
    @GetMapping("")
    fun moreGreeting(): String {
        val instanceInfo = eurekaClient
            .getApplication("spring-cloud-eureka-client")
            .instances[0]
        val url = instanceInfo.homePageUrl
        val targetUrl = "$url/greeting"

        val response = restTemplate.getForEntity(targetUrl, String::class.java)
        return response.body ?: "no data"
    }
}










### myapp/src/main/kotlin/ru/zavanton/myapp/client/GreetingClient.kt
package ru.zavanton.myapp.client

import org.springframework.cloud.openfeign.FeignClient
import org.springframework.web.bind.annotation.RequestMapping

@FeignClient("spring-cloud-eureka-client")
interface GreetingClient {

    @RequestMapping("/greeting")
    fun greeting(): String
}
