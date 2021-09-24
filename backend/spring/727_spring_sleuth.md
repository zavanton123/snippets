# Spring Cloud - how to use Sleuth (trace id vs span id)?






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
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("org.springframework.cloud:spring-cloud-starter-feign:1.4.7.RELEASE")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	implementation("org.springframework.cloud:spring-cloud-starter-sleuth")
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










### app/src/main/resources/application.yml
spring:
  application:
    name: Zavanton Sleuth Demo
server:
  port: 9999










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










### app/src/main/kotlin/ru/zavanton/app/demo/config/ExecutorConfig.kt
package ru.zavanton.app.demo.config

import java.util.concurrent.Executor
import java.util.concurrent.Executors
import org.springframework.beans.factory.BeanFactory
import org.springframework.cloud.sleuth.instrument.async.LazyTraceExecutor
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.scheduling.annotation.AsyncConfigurerSupport
import org.springframework.scheduling.annotation.EnableAsync
import org.springframework.scheduling.annotation.EnableScheduling
import org.springframework.scheduling.annotation.SchedulingConfigurer
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor
import org.springframework.scheduling.config.ScheduledTaskRegistrar

@Configuration
@EnableAsync
@EnableScheduling
class ExecutorConfig(
    private val beanFactory: BeanFactory,
) : AsyncConfigurerSupport(), SchedulingConfigurer {

    @Bean
    fun executor(): Executor {
        val executor = ThreadPoolTaskExecutor()
            .also {
                it.corePoolSize = 1
                it.maxPoolSize = 1
                it.initialize()
            }
        // Note: LazyTraceExecutor enables different trace id for other threads
        return LazyTraceExecutor(beanFactory, executor)
    }

    override fun getAsyncExecutor(): Executor {
        val executor = ThreadPoolTaskExecutor()
            .also {
                it.corePoolSize = 1
                it.maxPoolSize = 1
                it.initialize()
            }
        // Note: LazyTraceExecutor enables different trace id for other threads
        return LazyTraceExecutor(beanFactory, executor)
    }

    override fun configureTasks(taskRegistrar: ScheduledTaskRegistrar) {
        taskRegistrar.setScheduler(schedulingExecutor())
    }

    @Bean(destroyMethod = "shutdown")
    fun schedulingExecutor(): Executor {
        return Executors.newScheduledThreadPool(1)
    }
}










### app/src/main/kotlin/ru/zavanton/app/demo/controller/SleuthController.kt
package ru.zavanton.app.demo.controller

import java.util.concurrent.Executor
import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.app.demo.client.DemoClient
import ru.zavanton.app.demo.service.SleuthService

@RestController
class SleuthController(
    private val sleuthService: SleuthService,
    private val executor: Executor,
    private val demoClient: DemoClient,
) {

    private val log = LoggerFactory.getLogger(SleuthController::class.java)

    @GetMapping("")
    fun helloSleuth(): String {
        log.info("zavanton - hello sleuth")
        return "success"
    }

    @GetMapping("/same-span")
    fun sameSpan(): String {
        log.info("zavanton - same span")
        sleuthService.doSomeWork()
        return "same span"
    }

    @GetMapping("/new-span")
    fun newSpan(): String {
        log.info("zavanton - new span")
        sleuthService.doSomeWorkNewSpan()
        return "new span"
    }

    @GetMapping("/new-thread")
    fun helloFromNewThread(): String {
        log.info("zavanton - hello from new thread -> BEGIN")

        // Note: the trace id in the new thread
        // will be different from the original trace id
        executor.execute {
            Thread.sleep(1000L)
            log.info("zavanton - I am inside a new thread...")
        }

        log.info("zavanton - hello from new thread -> END")
        return "new thread"
    }

    @GetMapping("/async")
    fun asyncDemo(): String {
        log.info("zavanton - asyncDemo START")
        sleuthService.demoAsync()
        log.info("zavanton - asyncDemo FINISH")
        return "async OK"
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










### app/src/main/kotlin/ru/zavanton/app/demo/service/SleuthService.kt
package ru.zavanton.app.demo.service

import org.slf4j.LoggerFactory
import org.springframework.cloud.sleuth.Tracer
import org.springframework.scheduling.annotation.Async
import org.springframework.stereotype.Service

@Service
class SleuthService(
    private val tracer: Tracer,
) {
    private val log = LoggerFactory.getLogger(SleuthService::class.java)

    fun doSomeWork() {
        Thread.sleep(1000L)
        log.info("zavanton - Doing some work...")
    }

    fun doSomeWorkNewSpan() {
        val newSpan = tracer.nextSpan().name("newSpan")
        tracer.withSpan(newSpan.start())
            .use {
                Thread.sleep(1000L)
                log.info("zavanton - I'm in the new span doing some cool work that needs its own span")
            }
    }

    // Note: this method is async
    @Async
    fun demoAsync() {
        log.info("zavanton - BEGIN async...")
        Thread.sleep(1000L)
        log.info("zavanton - END async...")
    }
}










### app/src/main/kotlin/ru/zavanton/app/demo/service/SchedulingService.kt
package ru.zavanton.app.demo.service

import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service

@Service
class SchedulingService(
    private val sleuthService: SleuthService,
) {
    private val log = LoggerFactory.getLogger(SchedulingService::class.java)

    @Scheduled(fixedDelay = 100000)
    fun scheduledWork() {
        log.info("zavanton - SCHEDULED START")
        sleuthService.demoAsync()
        log.info("zavanton - SCHEDULED END")
    }
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
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	implementation("org.springframework.cloud:spring-cloud-starter-sleuth")
	implementation("org.springframework.cloud:spring-cloud-starter-feign:1.4.7.RELEASE")
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










### info/src/main/resources/application.yml
spring:
  application:
    name: info-service
server:
  port: 7878










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
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	implementation("org.springframework.cloud:spring-cloud-starter-sleuth")
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










### details/src/main/resources/application.yml
spring:
  application:
    name: details-service
server:
  port: 8989










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
