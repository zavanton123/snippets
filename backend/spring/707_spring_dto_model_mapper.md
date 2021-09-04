# Spring - REST convert entity to DTO using ModelMapper


### resources/application.yml
server:
  port: 9999










### kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### kotlin/ru/zavanton/demo/config/ModelMapperConfig.kt
package ru.zavanton.demo.config

import org.modelmapper.ModelMapper
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class ModelMapperConfig {

    @Bean
    fun modelMapper(): ModelMapper {
        return ModelMapper()
    }
}










### kotlin/ru/zavanton/demo/data/Post.kt
package ru.zavanton.demo.data

class Post(
    var id: Long = 0L,
    var title: String = "",
    var content: String = "",
    var author: String = ""
)










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.modelmapper.ModelMapper
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.controller.dto.PostDTO
import ru.zavanton.demo.data.Post

@RestController
class MyController(
    private val modelMapper: ModelMapper
) {

    @GetMapping("/")
    fun demo(): String {
        return "demo"
    }

    @GetMapping("/posts/{id}")
    fun fetchPostById(
        @PathVariable id: Long
    ): PostDTO {
        val post = Post(
            0L,
            "First Post Title",
            "First Post Content",
            "zavanton"
        )
        // Note: use model mapper
        return modelMapper.map(post, PostDTO::class.java)
    }
}










### kotlin/ru/zavanton/demo/controller/dto/PostDTO.kt
package ru.zavanton.demo.controller.dto

class PostDTO(
    var id: Long = 0L,
    var title: String = "",
    var author: String = ""
)



```
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.4"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.21"
	kotlin("plugin.spring") version "1.5.21"
	kotlin("plugin.jpa") version "1.5.21"
}

group = "ru.zavanton"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_1_8

repositories {
	mavenCentral()
}

dependencies {
	implementation("javax.inject:javax.inject:1")
	implementation("org.springframework.boot:spring-boot-starter-data-jpa")
	implementation("org.springframework.boot:spring-boot-starter-thymeleaf")
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	runtimeOnly("com.h2database:h2")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
	implementation("org.modelmapper:modelmapper:2.4.4")
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
