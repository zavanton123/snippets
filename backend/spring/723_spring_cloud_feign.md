# Spring Cloud - OpenFeign configuration


### resources/application.yml
spring:
  application:
    name: api-lessons
# server port is set by eureka
server:
  port: 0
# setup eureka client
eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_URI:http://localhost:8761/eureka}
  instance:
    prefer-ip-address: true
# setup actuator endpoints
management:
  endpoints:
    web:
      exposure:
        include: '*'
  endpoint:
    health:
      show-details: always
# setup feign
feign:
  client:
    config:
      default:
        connectTimeout: 5000
        readTimeout: 5000
        loggerLevel: basic
  circuitbreaker:
    enabled: true
# setup logging for feign client
logging:
  level:
    com.evolunta.app.lessons.client: DEBUG










### kotlin/com/evolunta/app/lessons/LessonsApp.kt
package com.evolunta.app.lessons

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.netflix.eureka.EnableEurekaClient
import org.springframework.cloud.openfeign.EnableFeignClients

@SpringBootApplication
@EnableEurekaClient
@EnableFeignClients
class LessonsApp

fun main(args: Array<String>) {
	runApplication<LessonsApp>(*args)
}










### kotlin/com/evolunta/app/lessons/config/ClientConfig.kt
package com.evolunta.app.lessons.config

import feign.Logger
import feign.codec.ErrorDecoder
import feign.okhttp.OkHttpClient
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class ClientConfig {

//    // this client will be using OkHttp
//    @Bean
//    fun okHttpClient(): OkHttpClient {
//        return OkHttpClient()
//    }

    // this client will be using this logging level
    @Bean
    fun logging(): Logger.Level {
        return Logger.Level.FULL
    }

    // setup a custom error decoder for this client
    @Bean
    fun errorDecoder(): ErrorDecoder {
        return CustomErrorDecoder()
    }
}










### kotlin/com/evolunta/app/lessons/config/CustomErrorDecoder.kt
package com.evolunta.app.lessons.config

import feign.Response
import feign.codec.ErrorDecoder

class CustomErrorDecoder : ErrorDecoder {

    override fun decode(methodKey: String, response: Response): Exception {
        return RuntimeException("some custom runtime exception...")
    }
}










### kotlin/com/evolunta/app/lessons/data/Course.kt
package com.evolunta.app.lessons.data

class Course(
    var id: Long = 0L,
    var title: String = ""
) 










### kotlin/com/evolunta/app/lessons/controller/LessonsController.kt
package com.evolunta.app.lessons.controller

import com.evolunta.app.lessons.client.CoursesClient
import com.evolunta.app.lessons.data.Course
import com.netflix.discovery.EurekaClient
import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class LessonsController(
    private val coursesClient: CoursesClient,
    private val eurekaClient: EurekaClient,
) {
    private val log = LoggerFactory.getLogger(LessonsController::class.java)

    @GetMapping("")
    fun lessons(): List<Course> {
        val info = eurekaClient.getApplication("api-courses")
            .instances[0]
        val url = info.homePageUrl
        log.info("zavanton - url: $url")

        return coursesClient.fetchCourses()
    }
}










### kotlin/com/evolunta/app/lessons/client/CoursesClient.kt
package com.evolunta.app.lessons.client

import com.evolunta.app.lessons.config.ClientConfig
import com.evolunta.app.lessons.data.Course
import org.springframework.cloud.openfeign.FeignClient
import org.springframework.web.bind.annotation.GetMapping

@FeignClient(
    value = "api-courses",
    configuration = [ClientConfig::class],
    fallback = CourseClientFallback::class
)
interface CoursesClient {

    @GetMapping("/courses")
    fun fetchCourses(): List<Course>
}










### kotlin/com/evolunta/app/lessons/client/CourseClientFallback.kt
package com.evolunta.app.lessons.client

import com.evolunta.app.lessons.data.Course
import org.springframework.stereotype.Component

@Component
class CourseClientFallback : CoursesClient {

    override fun fetchCourses(): List<Course> {
        return emptyList()
    }
}

### build.gradle.kts
```
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.4"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.21"
	kotlin("plugin.spring") version "1.5.21"
	kotlin("plugin.jpa") version "1.5.21"
}

group = "com.evolunta.app"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_1_8

repositories {
	mavenCentral()
}

extra["springCloudVersion"] = "2020.0.3"

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-actuator")
	implementation("org.springframework.boot:spring-boot-starter-data-jpa")
	implementation("org.springframework.boot:spring-boot-starter-validation")
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	implementation("org.springframework.cloud:spring-cloud-starter-netflix-eureka-client")
	implementation("org.springframework.cloud:spring-cloud-starter-openfeign")
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	runtimeOnly("com.h2database:h2")
    // OkHttp for Feign
	implementation("io.github.openfeign:feign-okhttp:11.6")
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

```
