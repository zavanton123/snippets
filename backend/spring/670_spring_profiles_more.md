# Spring - Core, Profiles, how to enable profiles via spring_active_profiles env variable? @ActiveProfiles, profile groups



### test/kotlin/ru/zavanton/demo/AppTests.kt
package ru.zavanton.demo

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class AppTests {

	@Test
	fun contextLoads() {
	}

}










### test/kotlin/ru/zavanton/demo/repository/StudentRepositoryDevTest.kt
package ru.zavanton.demo.repository

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles

@SpringBootTest
@ActiveProfiles("dev")
class StudentRepositoryDevTest {

    @Autowired
    lateinit var studentRepository: StudentRepository

    @Test
    fun testProfile() {
        // mock
        val expected = "hello dev"

        // action
        val actual = studentRepository.hello()

        // verify
        assertThat(expected).isEqualTo(actual)
    }
}










### test/kotlin/ru/zavanton/demo/repository/StudentRepositoryProdTest.kt
package ru.zavanton.demo.repository

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles

@SpringBootTest
@ActiveProfiles("prod")
class StudentRepositoryProdTest {

    @Autowired
    lateinit var studentRepository: StudentRepository

    @Test
    fun testProfile() {
        // mock
        val expected = "hello prod"

        // action
        val actual = studentRepository.hello()

        // verify
        assertThat(expected).isEqualTo(actual)
    }
}










### main/resources/application-dev.yml
database-url: localhost:5432/test-db










### main/resources/application-prod.yml
database-url: 10.24.65.01:5432/test-db










### main/resources/application.yml
server:
  port: 9999

spring:
  # set the default profile to 'dev'
  profiles:
    default: dev
    # setup the profile groups
    group:
      zavantontestgroup:
        - dev
        - test
      zavantonprodgroup:
        - prod
        - preprod


---
spring:
  config:
    activate:
      on-profile: dev

database-username: test-user


---
spring:
  config:
    activate:
      on-profile: prod

database-username: prod-user










### main/kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### main/kotlin/ru/zavanton/demo/repository/DevStudentRepositoryImpl.kt
package ru.zavanton.demo.repository

import org.springframework.context.annotation.Profile
import org.springframework.stereotype.Repository

@Profile("dev")
@Repository
class DevStudentRepositoryImpl : StudentRepository {

    override fun hello(): String = "hello dev"
}










### main/kotlin/ru/zavanton/demo/repository/StudentRepository.kt
package ru.zavanton.demo.repository

// Note: to enable dev profile, create the environment variable spring_profiles_active=dev
// Or create JVM variable -Dspring.profiles.active=dev
interface StudentRepository {

    fun hello(): String
}










### main/kotlin/ru/zavanton/demo/repository/ProdStudentRepositoryImpl.kt
package ru.zavanton.demo.repository

import org.springframework.context.annotation.Profile
import org.springframework.stereotype.Repository

@Profile("prod")
@Repository
class ProdStudentRepositoryImpl : StudentRepository {

    override fun hello(): String = "hello prod"
}










### main/kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.core.env.Environment
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.repository.StudentRepository

@RestController
class MyController(
    private val studentRepository: StudentRepository,
    private val environment: Environment,

    @Value("\${spring.profiles.active}")
    private val activeProfile: String,

    @Value("\${database-url}")
    private val dbUrl: String,

    @Value("\${database-username}")
    private val dbUsername: String,
) {
    private val log = LoggerFactory.getLogger(MyController::class.java)

    @GetMapping("")
    fun home(): String {
        log.info("zavanton - the active profile is: $activeProfile")
        log.info("zavanton - dbUrl: $dbUrl")
        log.info("zavanton - dbUsername: $dbUsername")

        val profiles: Array<String> = environment.activeProfiles
        profiles.forEach { profile ->
            log.info("zavanton - active profiles: $profile")
        }
        return studentRepository.hello()
    }
}
