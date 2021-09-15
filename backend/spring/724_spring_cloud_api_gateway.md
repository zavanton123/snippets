# Spring Boot - Microservices with Spring Boot Api Gateway and Eureka Server, Eureka Client





## GATEWAY SERVICE
### gateway/build.gradle.kts
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.4"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.21"
	kotlin("plugin.spring") version "1.5.21"
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
	implementation("org.springframework.boot:spring-boot-starter-webflux")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	implementation("io.projectreactor.kotlin:reactor-kotlin-extensions")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	// resilience circuit breaker
	implementation("org.springframework.cloud:spring-cloud-starter-circuitbreaker-reactor-resilience4j")
//	// redis reactive (used for rate limiting)
//	implementation("org.springframework.boot:spring-boot-starter-data-redis-reactive")
	implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
	implementation("org.springframework.cloud:spring-cloud-starter-gateway")
	implementation("org.springframework.cloud:spring-cloud-starter-netflix-eureka-client")
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
	testImplementation("io.projectreactor:reactor-test")
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










### gateway/src/main/resources/application.yml
server:
  port: 9999
spring:
  application:
    name: gateway-service
  # setup gateway
  cloud:
    gateway:
      discovery:
        locator:
          enabled: true
          lower-case-service-id: true
      # Note: you can get info about the routes at:
      # http://localhost:9999/actuator/gateway/routes
      routes:
#        - id: courses-route
#          uri: lb://api-courses
#          predicates:
#            - Path=/api/courses/**
#          filters:
#            - RewritePath=/api(?<path>/?.*), $\{path}
#        - id: lessons-route
#          uri: lb://api-lessons
#          predicates:
#            - Path=/api/lessons/**
#          filters:
#            - StripPrefix=1
        - id: golden-route
          uri: lb://api-golden
          predicates:
            - Path=/api/golden/medal/**
          filters:
            - StripPrefix=2
        - id: silver-route
          uri: lb://api-silver
          predicates:
            - Path=/api/silver/medal/**
          filters:
            - StripPrefix=2
        - id: zavanton-route
          uri: http://data.zavanton.ru
          predicates:
            - Path=/zavanton/**
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










### gateway/src/main/kotlin/com/evolunta/app/gateway/GatewayApp.kt
package com.evolunta.app.gateway

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.netflix.eureka.EnableEurekaClient

@SpringBootApplication
@EnableEurekaClient
class GatewayApp

fun main(args: Array<String>) {
	runApplication<GatewayApp>(*args)
}










### gateway/src/main/kotlin/com/evolunta/app/gateway/config/GatewayConfig.kt
package com.evolunta.app.gateway.config

import org.springframework.cloud.gateway.route.RouteLocator
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class GatewayConfig {

    // note: this is the same as the configuration in application.yml
    @Bean
    fun routeLocator(builder: RouteLocatorBuilder): RouteLocator {
        return builder.routes()
            .route("courses-route") { predicateSpec ->
                predicateSpec.path("/api/courses/**")
                    .filters {
                        it.rewritePath("/api(?<path>/?.*)", "\${path}")
                    }
                    .uri("lb://api-courses")
            }
            .route("lessons-route") { predicateSpec ->
                predicateSpec.path("/api/lessons/**")
                    .filters {
                        it.stripPrefix(1)
                    }
                    .uri("lb://api-lessons")
            }
//            .route("golden-route") { predicateSpec ->
//                predicateSpec.path("/api/golden/medal/**")
//                    .filters {
//                        it.stripPrefix(2)
//                    }
//                    .uri("lb://api-golden")
//            }
//            .route("silver-route") { predicateSpec ->
//                predicateSpec.path("/api/silver/medal/**")
//                    .filters {
//                        it.stripPrefix(2)
//                    }
//                    .uri("lb://api-silver")
//            }
//            .route("zavanton-route") { predicateSpec ->
//                predicateSpec.path("/zavanton/**")
//                    .uri("http://data.zavanton.ru")
//            }
            .build()
    }
}













## DISCOVERY SERVICE
### discovery-server/build.gradle.kts
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.4"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.21"
	kotlin("plugin.spring") version "1.5.21"
}

group = "com.evolunta.app"
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










### discovery-server/src/main/resources/application.yml
server:
  port: 8761
eureka:
  client:
    register-with-eureka: false
    fetch-registry: false










### discovery-server/src/main/kotlin/com/evolunta/app/discovery/DiscoveryServerApp.kt
package com.evolunta.app.discovery

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer

@SpringBootApplication
@EnableEurekaServer
class DiscoveryServerApp

fun main(args: Array<String>) {
	runApplication<DiscoveryServerApp>(*args)
}










## LESSONS SERVICE
### lessons/build.gradle.kts
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










### lessons/src/main/resources/application.yml
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










### lessons/src/main/kotlin/com/evolunta/app/lessons/LessonsApp.kt
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










### lessons/src/main/kotlin/com/evolunta/app/lessons/config/ClientConfig.kt
package com.evolunta.app.lessons.config

import feign.Logger
import feign.codec.ErrorDecoder
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class ClientConfig {

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










### lessons/src/main/kotlin/com/evolunta/app/lessons/config/CustomErrorDecoder.kt
package com.evolunta.app.lessons.config

import feign.Response
import feign.codec.ErrorDecoder

class CustomErrorDecoder : ErrorDecoder {

    override fun decode(methodKey: String, response: Response): Exception {
        return RuntimeException("some custom runtime exception...")
    }
}










### lessons/src/main/kotlin/com/evolunta/app/lessons/data/Course.kt
package com.evolunta.app.lessons.data

class Course(
    var id: Long = 0L,
    var title: String = ""
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as Course

        if (id != other.id) return false
        if (title != other.title) return false

        return true
    }

    override fun hashCode(): Int {
        var result = id.hashCode()
        result = 31 * result + title.hashCode()
        return result
    }

    override fun toString(): String {
        return "Course(id=$id, title='$title')"
    }
}










### lessons/src/main/kotlin/com/evolunta/app/lessons/controller/LessonsController.kt
package com.evolunta.app.lessons.controller

import com.evolunta.app.lessons.client.CoursesClient
import com.evolunta.app.lessons.data.Course
import com.netflix.discovery.EurekaClient
import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/lessons")
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










### lessons/src/main/kotlin/com/evolunta/app/lessons/client/CoursesClient.kt
package com.evolunta.app.lessons.client

import com.evolunta.app.lessons.config.ClientConfig
import com.evolunta.app.lessons.data.Course
import org.springframework.cloud.openfeign.FeignClient
import org.springframework.context.annotation.Primary
import org.springframework.web.bind.annotation.GetMapping

@FeignClient(
    value = "api-courses",
    configuration = [ClientConfig::class],
    fallback = CourseClientFallback::class
)
@Primary
interface CoursesClient {

    @GetMapping("/courses")
    fun fetchCourses(): List<Course>
}










### lessons/src/main/kotlin/com/evolunta/app/lessons/client/CourseClientFallback.kt
package com.evolunta.app.lessons.client

import com.evolunta.app.lessons.data.Course
import org.springframework.stereotype.Component

@Component
class CourseClientFallback : CoursesClient {

    override fun fetchCourses(): List<Course> {
        return emptyList()
    }
}










## COURSES SERVICE
### courses/build.gradle.kts
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
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	runtimeOnly("com.h2database:h2")
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










### courses/src/main/resources/application.yml
spring:
  application:
    name: api-courses
# server port is configured by eureka
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










### courses/src/main/kotlin/com/evolunta/app/courses/CoursesApp.kt
package com.evolunta.app.courses

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.netflix.eureka.EnableEurekaClient

@SpringBootApplication
@EnableEurekaClient
class CoursesApp

fun main(args: Array<String>) {
	runApplication<CoursesApp>(*args)
}










### courses/src/main/kotlin/com/evolunta/app/courses/data/Course.kt
package com.evolunta.app.courses.data

class Course(
    var id: Long = 0L,
    var title: String = ""
)  {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as Course

        if (id != other.id) return false
        if (title != other.title) return false

        return true
    }

    override fun hashCode(): Int {
        var result = id.hashCode()
        result = 31 * result + title.hashCode()
        return result
    }

    override fun toString(): String {
        return "Course(id=$id, title='$title')"
    }
}










### courses/src/main/kotlin/com/evolunta/app/courses/controller/CourseController.kt
package com.evolunta.app.courses.controller

import com.evolunta.app.courses.data.Course
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/courses")
class CourseController {

    @GetMapping("")
    fun courses(): List<Course> {
        return listOf(
            Course(0L, "CS"),
            Course(1L, "Math"),
            Course(2L, "Algorithms & Data Structures")
        )
    }
}










## SILVER SERVICE
### silver-service/build.gradle.kts
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.4"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.21"
	kotlin("plugin.spring") version "1.5.21"
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










### silver-service/src/main/resources/application.yml
spring:
  application:
    name: api-silver
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










### silver-service/src/main/kotlin/com/evolunta/app/silver/SilverApp.kt
package com.evolunta.app.silver

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.netflix.eureka.EnableEurekaClient

@SpringBootApplication
@EnableEurekaClient
class SilverApp

fun main(args: Array<String>) {
	runApplication<SilverApp>(*args)
}










### silver-service/src/main/kotlin/com/evolunta/app/silver/controller/SilverController.kt
package com.evolunta.app.silver.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/medal")
class SilverController {

    @GetMapping("")
    fun medal(): String {
        return "this is a silver medal"
    }
}










## GOLDEN SERVICE
### golden-service/build.gradle.kts
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.4"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.21"
	kotlin("plugin.spring") version "1.5.21"
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










### golden-service/src/main/resources/application.yml
spring:
  application:
    name: api-golden
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










### golden-service/src/main/kotlin/com/evolunta/app/golden/GoldenApp.kt
package com.evolunta.app.golden

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.cloud.netflix.eureka.EnableEurekaClient

@SpringBootApplication
@EnableEurekaClient
class GoldenApp

fun main(args: Array<String>) {
	runApplication<GoldenApp>(*args)
}










### golden-service/src/main/kotlin/com/evolunta/app/golden/controller/GoldenController.kt
package com.evolunta.app.golden.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/medal")
class GoldenController {

    @GetMapping("")
    fun medal(): String {
        return "this is a golden medal"
    }
}
