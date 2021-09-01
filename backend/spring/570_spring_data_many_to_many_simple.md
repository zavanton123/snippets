# Spring - Data, Many to many relationships (simple - join table has no additional attributes)



### resources/application.yml
server:
  port: 9999

spring:
  datasource:
    driverClassName: org.h2.Driver
    password: admin
    url: jdbc:h2:mem:testdb
    username: admin
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










### kotlin/ru/zavanton/demo/repository/StudentRepository.kt
package ru.zavanton.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Student

@Repository
interface StudentRepository : JpaRepository<Student, Long> {
}










### kotlin/ru/zavanton/demo/repository/CourseRepository.kt
package ru.zavanton.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Course

@Repository
interface CourseRepository : JpaRepository<Course, Long> {
}










### kotlin/ru/zavanton/demo/runner/DataInitializer.kt
package ru.zavanton.demo.runner

import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component
import ru.zavanton.demo.entity.Course
import ru.zavanton.demo.entity.Student
import ru.zavanton.demo.repository.StudentRepository

@Component
class DataInitializer(
    private val studentRepository: StudentRepository,
) : CommandLineRunner {

    override fun run(vararg args: String) {
        val student1 = Student(name = "Mike")
        val student2 = Student(name = "Jack")

        val course = Course(name = "CS")

        student1.addCourse(course)
        course.addStudent(student2)

        studentRepository.saveAll(listOf(student1, student2))
    }
}










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class MyController {

    @GetMapping("")
    fun home(): String {
        return "ok"
    }
}










### kotlin/ru/zavanton/demo/entity/Student.kt
package ru.zavanton.demo.entity

import javax.persistence.CascadeType
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.JoinTable
import javax.persistence.ManyToMany

@Entity
data class Student(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0L,
    var name: String = ""
) {
    @ManyToMany(cascade = [CascadeType.ALL])
    @JoinTable(
        name = "enrollment",
        joinColumns = [JoinColumn(name = "student_id", referencedColumnName = "id")],
        inverseJoinColumns = [JoinColumn(name = "course_id", referencedColumnName = "id")]
    )
    val courses: MutableSet<Course> = mutableSetOf()

    fun addCourse(course: Course) {
        courses.add(course)
        course.students.add(this)
    }
}










### kotlin/ru/zavanton/demo/entity/Course.kt
package ru.zavanton.demo.entity

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.ManyToMany

@Entity
data class Course(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0L,
    var name: String = ""
) {
    @ManyToMany(mappedBy = "courses")
    val students: MutableSet<Student> = mutableSetOf()

    fun addStudent(student: Student) {
        students.add(student)
        student.courses.add(this)
    }
}
