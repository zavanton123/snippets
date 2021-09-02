# Spring - Core, properties, @PropertySource, @TestPropertySource, environment.getProperty()



### test/resources/application.properties
demo-count=123










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










### test/kotlin/ru/zavanton/demo/PropertyTest.kt
package ru.zavanton.demo

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.core.env.Environment
import org.springframework.test.context.TestPropertySource
import org.springframework.test.context.TestPropertySources

@SpringBootTest(properties = ["last_name=Jackson"])
@TestPropertySources(
    TestPropertySource("classpath:test.properties"),
    TestPropertySource(properties = ["first_name=Tom"])
)
class PropertyTest {

    @Autowired
    private lateinit var environment: Environment

    @Value("\${demo-count}")
    private lateinit var count: String

    @Value("\${first_name}")
    private lateinit var firstName: String

    @Test
    fun testProperties() {
        val expected = "some-test-db-name"
        val actual = environment.getProperty("test-db-name")
        assertEquals(expected, actual)
    }

    @Test
    fun testMoreProperties() {
        val expected = 123
        val actual = count.toInt()
        assertEquals(expected, actual)
    }

    @Test
    fun testFullName() {
        val expectedFirstName = "Tom"
        val expectedLastName = "Jackson"
        assertEquals(expectedFirstName, firstName)
        assertEquals(expectedLastName, environment.getProperty("last_name"))
    }
}










### main/resources/persistence-mysql.properties
database-name=demo-mysql-db-name










### main/resources/test.properties
test-db-name:some-test-db-name










### main/resources/persistence-postgres.properties
database-name=demo-postgres-db-name










### main/resources/application.yml
server:
  port: 9999










### main/kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### main/kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.PropertySource
import org.springframework.core.env.Environment
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@PropertySource(
    "classpath:persistence-\${envTarget:mysql}.properties"
)
class MyController(
    @Value("\${database-name}")
    private val dbName: String,

    private val environment: Environment,
) {
    private val log = LoggerFactory.getLogger(MyController::class.java)

    @GetMapping("")
    fun home(): String {
        log.info("zavanton - dbName: $dbName")

        val databaseName = environment.getProperty("database-name") ?: "default db name"
        log.info("zavanton - databaseName: $databaseName")
        return "home"
    }
}
