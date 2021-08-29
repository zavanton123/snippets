# Spring - Data, manual Transactions with TransactionTemplate and PlatformTransactionManager



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










### kotlin/ru/zavanton/demo/data/Department.kt
package ru.zavanton.demo.data

enum class Department {
    IT,
    ACCOUNTING,
    SALES,
}










### kotlin/ru/zavanton/demo/data/Employee.kt
package ru.zavanton.demo.data

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.EnumType
import javax.persistence.Enumerated
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
data class Employee(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,

    @Column(name = "full_name", unique = true)
    val name: String = "",

    @Enumerated(EnumType.STRING)
    @Column(name = "company_department")
    val department: Department = Department.IT
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
        val employee = employeeService.saveEmployee1(request)
        return "Success! Employee id: ${employee.id}"
    }
}










### kotlin/ru/zavanton/demo/controller/CreateEmployeeRequest.kt
package ru.zavanton.demo.controller

data class CreateEmployeeRequest(
    val name: String = ""
)










### kotlin/ru/zavanton/demo/service/TransactionTemplateServiceImpl.kt
package ru.zavanton.demo.service

import java.sql.SQLException
import org.springframework.stereotype.Service
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.support.TransactionTemplate
import ru.zavanton.demo.controller.CreateEmployeeRequest
import ru.zavanton.demo.data.Employee
import ru.zavanton.demo.repository.EmployeeRepository

@Service
class TransactionTemplateServiceImpl(
    private val employeeRepository: EmployeeRepository,
    private val transactionManager: PlatformTransactionManager
) : EmployeeService {

    override fun saveEmployee1(request: CreateEmployeeRequest): Employee {
        val transactionTemplate = TransactionTemplate(transactionManager)

        val resultingEmployee: Employee? = transactionTemplate.execute { transactionStatus ->
            val employee = Employee(name = request.name)
            val savedEmployee = employeeRepository.save(employee)
            // the rollback is caused by this exception
            throw SQLException("Some sql exception")

            // the rollback can also be caused by calling setRollbackOnly()
            transactionStatus.setRollbackOnly()

            savedEmployee
        }
        return resultingEmployee ?: throw RuntimeException("Something went wrong...")
    }

    override fun saveEmployee2(request: CreateEmployeeRequest): Employee {
        val transactionTemplate = TransactionTemplate(transactionManager)
        transactionTemplate.executeWithoutResult {
            val employee = Employee(name = request.name)
            employeeRepository.save(employee)

            // the rollback is caused by this exception
            throw SQLException("Some sql exception")
        }
        throw SQLException("Some sql exception")
    }
}










### kotlin/ru/zavanton/demo/service/PlatformTransactionManagerServiceImpl.kt
package ru.zavanton.demo.service

import java.sql.SQLException
import org.springframework.context.annotation.Primary
import org.springframework.stereotype.Service
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.TransactionDefinition
import org.springframework.transaction.TransactionStatus
import org.springframework.transaction.support.DefaultTransactionDefinition
import ru.zavanton.demo.controller.CreateEmployeeRequest
import ru.zavanton.demo.data.Employee
import ru.zavanton.demo.repository.EmployeeRepository

@Primary
@Service
class PlatformTransactionManagerServiceImpl(
    private val employeeRepository: EmployeeRepository,
    private val platformTransactionManager: PlatformTransactionManager,
) : EmployeeService {

    override fun saveEmployee1(request: CreateEmployeeRequest): Employee {
        var savedEmployee: Employee? = null

        val definition = DefaultTransactionDefinition()
        definition.isolationLevel = TransactionDefinition.ISOLATION_REPEATABLE_READ
        definition.timeout = 3
        val status: TransactionStatus = platformTransactionManager.getTransaction(definition)

        try {
            val employee = Employee(name = request.name)
            savedEmployee = employeeRepository.save(employee)
            // this error causes rollback...
            throw SQLException("SQL error here...")
            platformTransactionManager.commit(status)

        } catch (exception: SQLException) {
            platformTransactionManager.rollback(status)
        }
        return savedEmployee ?: throw RuntimeException("Some exception...")
    }

    override fun saveEmployee2(request: CreateEmployeeRequest): Employee {
        throw RuntimeException("not implemented")
    }
}










### kotlin/ru/zavanton/demo/service/EmployeeService.kt
package ru.zavanton.demo.service

import ru.zavanton.demo.controller.CreateEmployeeRequest
import ru.zavanton.demo.data.Employee

interface EmployeeService {

    fun saveEmployee1(request: CreateEmployeeRequest): Employee

    fun saveEmployee2(request: CreateEmployeeRequest): Employee
}










### kotlin/ru/zavanton/demo/service/TransactionalAnnotationServiceImpl.kt
package ru.zavanton.demo.service

import java.sql.SQLException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Isolation
import org.springframework.transaction.annotation.Propagation
import ru.zavanton.demo.controller.CreateEmployeeRequest
import ru.zavanton.demo.data.Employee
import ru.zavanton.demo.repository.EmployeeRepository

@Service
class TransactionalAnnotationServiceImpl(
    private val employeeRepository: EmployeeRepository
) : EmployeeService {

    // How does it work?
    // Something like this is added to the proxy:
    //
    // createTransactionIfNecessary();
    //try {
    //    callMethod();
    //    commitTransactionAfterReturning();
    //} catch (exception) {
    //    completeTransactionAfterThrowing();
    //    throw exception;
    //}
    @javax.transaction.Transactional(rollbackOn = [SQLException::class])
    override fun saveEmployee1(request: CreateEmployeeRequest): Employee {
        val employee = Employee(name = request.name)
        employeeRepository.save(employee)
        throw SQLException("Demo SQL exception")
    }

    @org.springframework.transaction.annotation.Transactional(
        rollbackFor = [SQLException::class],
        propagation = Propagation.REQUIRED,
        isolation = Isolation.DEFAULT
    )
    override fun saveEmployee2(request: CreateEmployeeRequest): Employee {
        val employee = Employee(name = request.name)
        employeeRepository.save(employee)
        throw SQLException("Demo SQL exception")
    }
}
