# Spring - how to use @Transactional?



### resources/application.yml
server:
  port: 9999

spring:
  h2:
    console:
      enabled: true
      path: /h2/
      settings:
        trace: false
        web-allow-others: false
  jpa:
    database-platform: org.hibernate.dialect.H2Dialect
    defer-datasource-initialization: true










### kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
	runApplication<App>(*args)
}










### kotlin/ru/zavanton/demo/repository/EmployeeRepository.kt
package ru.zavanton.demo.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.data.Employee

@Repository
interface EmployeeRepository : JpaRepository<Employee, Long> {
}










### kotlin/ru/zavanton/demo/config/DataSourceConfig.kt
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










### kotlin/ru/zavanton/demo/config/DataInitializer.kt
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










### kotlin/ru/zavanton/demo/data/Employee.kt
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










### kotlin/ru/zavanton/demo/controller/SqlExceptionHandler.kt
package ru.zavanton.demo.controller

import java.sql.SQLException
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ControllerAdvice
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.ResponseStatus

@ControllerAdvice
class SqlExceptionHandler {

    @ExceptionHandler(SQLException::class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    fun handleSqlException(exception: SQLException): ResponseEntity<String> {
        return ResponseEntity
            .status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(exception.message ?: "some error...")
    }
}










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.service.EmployeeService

@RestController
class MyController(
    private val employeeService: EmployeeService,
) {

    @PostMapping("/employees/create")
    @ResponseStatus(HttpStatus.CREATED)
    fun createEmployee(
        @RequestBody request: CreateEmployeeRequest
    ): String {
//        employeeService.saveEmployee1(request)
        employeeService.saveEmployee2(request)
        return "Success!"
    }
}










### kotlin/ru/zavanton/demo/controller/CreateEmployeeRequest.kt
package ru.zavanton.demo.controller

data class CreateEmployeeRequest(
    val name: String = ""
)










### kotlin/ru/zavanton/demo/service/EmployeeService.kt
package ru.zavanton.demo.service

import java.sql.SQLException
import org.springframework.stereotype.Service
import ru.zavanton.demo.controller.CreateEmployeeRequest
import ru.zavanton.demo.data.Employee
import ru.zavanton.demo.repository.EmployeeRepository

@Service
class EmployeeService(
    private val employeeRepository: EmployeeRepository
) {

    @javax.transaction.Transactional(rollbackOn = [SQLException::class])
    fun saveEmployee1(request: CreateEmployeeRequest): Employee {
        val employee = Employee(name = request.name)
        employeeRepository.save(employee)
        throw SQLException("Demo SQL exception")
    }

    @org.springframework.transaction.annotation.Transactional(rollbackFor = [SQLException::class])
    fun saveEmployee2(request: CreateEmployeeRequest): Employee {
        val employee = Employee(name = request.name)
        employeeRepository.save(employee)
        throw SQLException("Demo SQL exception")
    }
}
