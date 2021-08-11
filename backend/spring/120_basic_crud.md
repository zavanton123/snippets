# Spring Basic CRUD




### build.gradle
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.3"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.21"
	kotlin("plugin.spring") version "1.5.21"
	kotlin("plugin.jpa") version "1.5.21"
}

group = "com.slongly"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_1_8

repositories {
	mavenCentral()
}

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-data-jpa")
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
	runtimeOnly("com.h2database:h2:1.4.200")
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








### resources/application.yml
server:
  port: 8989

spring:
  datasource:
    driver-class-name: org.h2.Driver
    url: jdbc:h2:mem:testdb
    username: admin
    password: admin
  h2:
    console:
      enabled: true
      path: /h2/
      settings:
        trace: false
        web-allow-others: false
  jpa:
    database-platform: org.hibernate.dialect.H2Dialect










### kotlin/com/slongly/api/App.kt
package com.slongly.api

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class JokesApiApplication

fun main(args: Array<String>) {
    runApplication<JokesApiApplication>(*args)
}










### kotlin/com/slongly/api/controllers/JokeController.kt
package com.slongly.api.controllers

import com.slongly.api.data.Joke
import com.slongly.api.services.JokeService
import org.springframework.web.bind.annotation.*

@RestController
class JokeController(
    private val jokeService: JokeService
) {

    @GetMapping("/jokes")
    fun fetchJokes(): List<Joke> {
        return jokeService.fetchJokes()
    }

    @GetMapping("/jokes/{id}")
    fun fetchJokeById(@PathVariable("id") id: Int): Joke {
        return jokeService.fetchJokeById(id)
    }

    @PostMapping("/jokes")
    fun createJoke(@RequestBody joke: Joke): Joke {
        return jokeService.createJoke(joke)
    }

    @PatchMapping("/jokes/{id}")
    fun patchJoke(
        @PathVariable("id") id: Int,
        @RequestBody joke: Joke
    ): Joke {
        val updatedJoke = Joke(id = id, content = joke.content)
        return jokeService.patchJoke(updatedJoke)
    }

    @DeleteMapping("/jokes/{id}")
    fun deleteJoke(@PathVariable("id") id: Int) {
        return jokeService.deleteJoke(id)
    }

}










### kotlin/com/slongly/api/data/Joke.kt
package com.slongly.api.data

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id

@Entity
data class Joke(
    @Id
    @GeneratedValue
    var id: Int? = null,
    val content: String
)










### kotlin/com/slongly/api/services/JokeService.kt
package com.slongly.api.services

import com.slongly.api.data.Joke

interface JokeService {

    fun fetchJokes(): List<Joke>

    fun fetchJokeById(id: Int): Joke

    fun createJoke(joke: Joke): Joke

    fun patchJoke(joke: Joke): Joke

    fun deleteJoke(id: Int)

}










### kotlin/com/slongly/api/services/JokeServiceImpl.kt
package com.slongly.api.services

import com.slongly.api.data.Joke
import com.slongly.api.exceptions.JokeNotFound
import com.slongly.api.repositories.JokeRepository
import org.springframework.stereotype.Service

@Service
class JokeServiceImpl(
    private val jokeRepository: JokeRepository
) : JokeService {

    override fun fetchJokes(): List<Joke> {
        return jokeRepository.findAll().toList()
    }

    override fun fetchJokeById(id: Int): Joke {
        val optional = jokeRepository.findById(id)
        return if (optional.isPresent) {
            optional.get()
        } else {
            throw JokeNotFound()
        }
    }

    override fun createJoke(joke: Joke): Joke {
        return jokeRepository.save(joke)
    }

    override fun patchJoke(joke: Joke): Joke {
        return jokeRepository.save(joke)
    }

    override fun deleteJoke(id: Int) {
        return jokeRepository.deleteById(id)
    }
}










### kotlin/com/slongly/api/exceptions/JokeNotFound.kt
package com.slongly.api.exceptions

class JokeNotFound : RuntimeException("Joke Not Found") {
}










### kotlin/com/slongly/api/repositories/JokeRepository.kt
package com.slongly.api.repositories

import com.slongly.api.data.Joke
import org.springframework.data.repository.CrudRepository

interface JokeRepository : CrudRepository<Joke, Int> {
}
