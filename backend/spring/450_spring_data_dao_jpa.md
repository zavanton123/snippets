# Spring - Data, DAO using JPA



### resources/application.yml
server:
  port: 9999











### kotlin/ru/zavanton/api/App.kt
package ru.zavanton.api

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration
import org.springframework.boot.runApplication

@SpringBootApplication

class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### kotlin/ru/zavanton/api/dao/StudentDao.kt
package ru.zavanton.api.dao

import javax.persistence.EntityManager
import org.springframework.stereotype.Repository
import ru.zavanton.api.entity.Student

@Repository
class StudentDao(
    private val entityManager: EntityManager
) {

    fun save(student: Student) {
        entityManager.persist(student)
    }

    fun findById(id: Long): Student {
        return entityManager.find(Student::class.java, id)
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
implementation("org.springframework.boot:spring-boot-starter-data-jpa")
implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
implementation("org.jetbrains.kotlin:kotlin-reflect")
implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
developmentOnly("org.springframework.boot:spring-boot-devtools")
runtimeOnly("com.h2database:h2")
testImplementation("org.springframework.boot:spring-boot-starter-test")
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





