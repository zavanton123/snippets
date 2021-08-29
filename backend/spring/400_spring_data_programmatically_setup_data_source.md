# Spring - Data, configure DataSource programmatically; CommandLineRunner, @DataJpaTest



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










### test/kotlin/ru/zavanton/demo/repository/EmployeeRepositoryTest.kt
package ru.zavanton.demo.repository

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import ru.zavanton.demo.data.Employee

@DataJpaTest
class EmployeeRepositoryTest {

    @Autowired
    private lateinit var employeeRepository: EmployeeRepository

    @Test
    fun test_create() {
        // mock
        val employee = Employee(0L, "James Bond")
        employeeRepository.save(employee)

        // action
        val actual = employeeRepository.findAll()

        // verify
        assertThat(actual.size).isEqualTo(1)
    }
}










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










### main/kotlin/ru/zavanton/demo/repository/EmployeeRepository.kt
package ru.zavanton.demo.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.data.Employee

@Repository
interface EmployeeRepository : JpaRepository<Employee, Long> {
}










### main/kotlin/ru/zavanton/demo/config/DataSourceConfig.kt
package ru.zavanton.demo.config

import javax.sql.DataSource
import org.springframework.boot.jdbc.DataSourceBuilder
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class DataSourceConfig {

    @Bean
    fun dataSource(): DataSource {
        return DataSourceBuilder
            .create()
            .driverClassName("org.h2.Driver")
            .url("jdbc:h2:mem:testdb")
            .username("admin")
            .password("admin")
            .build()
    }
}










### main/kotlin/ru/zavanton/demo/config/DataInitializer.kt
package ru.zavanton.demo.config

import org.slf4j.LoggerFactory
import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component
import ru.zavanton.demo.data.Employee
import ru.zavanton.demo.repository.EmployeeRepository

@Component
class DataInitializer(
    private val employeeRepository: EmployeeRepository,
) : CommandLineRunner {

    private val log = LoggerFactory.getLogger(DataInitializer::class.java)

    override fun run(vararg args: String) {
        log.info("zavanton - running CommandLineRunner...")
        val employee1 = Employee(name = "James Bond")
        val employee2 = Employee(name = "Mike Tyson")
        val employee3 = Employee(name = "Tom Nickson")
        employeeRepository.saveAll(listOf(employee1, employee2, employee3))

        log.info("zavanton - the size of initial data: ${employeeRepository.count()}")
    }
}










### main/kotlin/ru/zavanton/demo/data/Employee.kt
package ru.zavanton.demo.data

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
data class Employee(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,

    @Column(name = "full_name")
    val name: String = ""
)
