# Spring - Data MongoDB (@Id, @Document, MongoTemplate, MongoRepository)




### resources/application.yml
server:
  port: 9999
spring:
  data:
    mongodb:
      host: 127.0.0.1
      port: 27017
      database: spring_demo_one










### kotlin/ru/zavanton/demo/DemoApplication.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class DemoApplication

fun main(args: Array<String>) {
	runApplication<DemoApplication>(*args)
}










### kotlin/ru/zavanton/demo/repository/StudentRepository.kt
package ru.zavanton.demo.repository

import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Student

@Repository
interface StudentRepository: MongoRepository<Student, Long> {
}










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.entity.Student
import ru.zavanton.demo.repository.StudentRepository
import ru.zavanton.demo.service.StudentService

@RestController
class MyController(
    private val studentRepository: StudentRepository,
    private val studentService: StudentService
) {

    @PostMapping("/students/create")
    fun saveStudent(): String {
        val student = Student(name = "Mike")
        studentService.save(student)
        return "ok"
    }

    @PostMapping("/students/update")
    fun updateStudent(): String {
        studentService.update()
        return "updated"
    }

    @PostMapping("/students/update_first")
    fun updateFirst(): String {
        studentService.updateFirst()
        return "updated first"
    }

    @GetMapping("/students/find/demo")
    fun findDemo(): String {
        val student = studentRepository.findById(0L)
        return "findDemo"
    }

    @PostMapping("/students/demo")
    fun demo(): String {
        val student = Student(name = "Nick")
        studentRepository.save(student)
        return "demo"
    }
}










### kotlin/ru/zavanton/demo/entity/Student.kt
package ru.zavanton.demo.entity

import java.math.BigInteger
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document

@Document
class Student(
    @Id
    var id: BigInteger? = null,
    var name: String = ""
)










### kotlin/ru/zavanton/demo/service/StudentService.kt
package ru.zavanton.demo.service

import org.springframework.data.mongodb.core.MongoTemplate
import org.springframework.data.mongodb.core.query.Criteria
import org.springframework.data.mongodb.core.query.Query
import org.springframework.data.mongodb.core.query.Update
import org.springframework.stereotype.Service
import ru.zavanton.demo.entity.Student

@Service
class StudentService(
    private val mongoTemplate: MongoTemplate
) {

    fun save(student: Student) {
        mongoTemplate.save(student, "student")
    }

    fun update() {
        val student = mongoTemplate.findOne(
            Query.query(Criteria.where("name").`is`("Mike")),
            Student::class.java
        ) ?: throw RuntimeException("Student not found")
        student.name = "Jack"
        mongoTemplate.save(student, "student")
    }

    fun updateFirst() {
        val query = Query()
        query.addCriteria(Criteria.where("name").`is`("Jack"))
        val update = Update()
        update.set("name", "Tom")
        mongoTemplate.updateFirst(query, update, Student::class.java)
    }

    fun updateMulti() {
        val query = Query()
        query.addCriteria(Criteria.where("name").`is`("Jack"))
        val update = Update()
        update.set("name", "Tom")
        mongoTemplate.updateMulti(query, update, Student::class.java)
    }

    fun findAndModify() {
        val query = Query()
        query.addCriteria(Criteria.where("name").`is`("Jack"))
        val update = Update()
        update.set("name", "Tom")
        val student = mongoTemplate.findAndModify(query, update, Student::class.java)
    }

    fun upsert() {
        val query = Query()
        query.addCriteria(Criteria.where("name").`is`("Jack"))
        val update = Update()
        update.set("name", "Tom")
        val student = mongoTemplate.upsert(query, update, Student::class.java)
    }

    fun remove() {
        val student = mongoTemplate.findOne(
            Query.query(Criteria.where("name").`is`("Mike")),
            Student::class.java
        ) ?: throw RuntimeException("Student not found")
        mongoTemplate.remove(student, "student")
    }
}
