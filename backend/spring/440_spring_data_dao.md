# Spring - How to use DAO?




### resources/application.yml
server:
  port: 9999











### kotlin/ru/zavanton/api/App.kt
package ru.zavanton.api

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration
import org.springframework.boot.runApplication

@SpringBootApplication(exclude = [HibernateJpaAutoConfiguration::class])
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### kotlin/ru/zavanton/api/config/HibernateConf.kt
package ru.zavanton.api.config

import java.util.Properties
import javax.sql.DataSource
import org.apache.tomcat.dbcp.dbcp2.BasicDataSource
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.orm.hibernate5.HibernateTransactionManager
import org.springframework.orm.hibernate5.LocalSessionFactoryBean
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.annotation.EnableTransactionManagement
import org.springframework.transaction.annotation.TransactionManagementConfigurer


@Configuration
@EnableTransactionManagement
class HibernateConf : TransactionManagementConfigurer {

    @Bean
    override fun annotationDrivenTransactionManager(): PlatformTransactionManager {
        val transactionManager = HibernateTransactionManager()
        transactionManager.sessionFactory = sessionFactory().getObject()
        return transactionManager
    }

    @Bean
    fun dataSource(): DataSource {
        val dataSource = BasicDataSource()
        dataSource.driverClassName = "org.h2.Driver"
        dataSource.url = "jdbc:h2:mem:db;DB_CLOSE_DELAY=-1"
        dataSource.username = "admin"
        dataSource.password = "admin"
        return dataSource
    }

    @Bean
    fun sessionFactory(): LocalSessionFactoryBean {
        val sessionFactory = LocalSessionFactoryBean()
        sessionFactory.setDataSource(dataSource())
        sessionFactory.setPackagesToScan("ru.zavanton.api.entity")
        sessionFactory.hibernateProperties = hibernateProperties()
        return sessionFactory
    }

    private fun hibernateProperties(): Properties {
        val hibernateProperties = Properties()
        hibernateProperties.setProperty("hibernate.hbm2ddl.auto", "create-drop")
        hibernateProperties.setProperty("hibernate.dialect", "org.hibernate.dialect.H2Dialect")
        return hibernateProperties
    }
}










### kotlin/ru/zavanton/api/dao/StudentDao.kt
package ru.zavanton.api.dao

import org.hibernate.SessionFactory
import org.springframework.stereotype.Repository
import ru.zavanton.api.entity.Student

@Repository
class StudentDao(
    private val sessionFactory: SessionFactory
) {

    fun save(student: Student) {
        sessionFactory.currentSession.persist(student)
    }

    fun findById(id: Long): Student {
        return sessionFactory.currentSession.find(Student::class.java, id)
    }
}










### kotlin/ru/zavanton/api/controller/MyController.kt
package ru.zavanton.api.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.api.entity.Student
import ru.zavanton.api.service.StudentService

@RestController
class MyController(
    private val studentService: StudentService
) {

    @GetMapping("")
    fun home(): String {
        val student = Student(0L, "Mike")
        studentService.save(student)

        val saved = studentService.findById(1L)
        return "ok - ${saved.name}"
    }
}










### kotlin/ru/zavanton/api/entity/Student.kt
package ru.zavanton.api.entity

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
data class Student(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,
    val name: String = ""
)










### kotlin/ru/zavanton/api/service/StudentService.kt
package ru.zavanton.api.service

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import ru.zavanton.api.dao.StudentDao
import ru.zavanton.api.entity.Student

@Service
class StudentService(
    private val studentDao: StudentDao
) {

    @Transactional
    fun save(student: Student) {
        studentDao.save(student)
    }

    @Transactional
    fun findById(id: Long): Student {
        return studentDao.findById(id)
    }
}










### build.gradle.kts
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
implementation("org.springframework.boot:spring-boot-starter-web")
implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
implementation("org.jetbrains.kotlin:kotlin-reflect")
implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
developmentOnly("org.springframework.boot:spring-boot-devtools")
runtimeOnly("com.h2database:h2")
testImplementation("org.springframework.boot:spring-boot-starter-test")
// hibernate core
implementation("org.hibernate:hibernate-core:5.5.7.Final")
// spring ORM
implementation("org.springframework:spring-orm:5.3.9")
// h2
implementation("com.h2database:h2:1.4.200")
// tomcat DBCP
implementation("org.apache.tomcat:tomcat-dbcp:10.0.10")
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
