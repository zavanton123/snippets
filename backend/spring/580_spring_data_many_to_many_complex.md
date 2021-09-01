# Spring - Data, Many to many relationships (complex - join table has some additional attributes)



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










### kotlin/ru/zavanton/demo/repository/EnrollmentRepository.kt
package ru.zavanton.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Enrollment

@Repository
interface EnrollmentRepository : JpaRepository<Enrollment, Long> {
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

import java.time.LocalDate
import java.util.Date
import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component
import ru.zavanton.demo.entity.Course
import ru.zavanton.demo.entity.Enrollment
import ru.zavanton.demo.entity.Student
import ru.zavanton.demo.repository.CourseRepository
import ru.zavanton.demo.repository.EnrollmentRepository
import ru.zavanton.demo.repository.StudentRepository

@Component
class DataInitializer(
    private val studentRepository: StudentRepository,
    private val courseRepository: CourseRepository,
    private val enrollmentRepository: EnrollmentRepository,
) : CommandLineRunner {

    override fun run(vararg args: String) {
        val student1 = Student(name = "Mike")
        val student2 = Student(name = "Jack")
        val course = Course(name = "CS")

        val enrollment1 = Enrollment(
            course = course,
            enrollmentDate = Date(
                LocalDate.now().plusDays(2).toEpochDay()
            )
        )
        val enrollment2 = Enrollment(
            student = student2,
            enrollmentDate = Date(
                LocalDate.now().minusDays(3).toEpochDay()
            )
        )
        student1.addEnrollment(enrollment1)
        course.addEnrollment(enrollment2)

        studentRepository.save(student1)
        courseRepository.save(course)

        val student3 = Student(name = "Tom")
        val course2 = Course(name = "Math")
        val enrollment3 = Enrollment(student = student3, course = course2)
        enrollmentRepository.save(enrollment3)
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
import javax.persistence.OneToMany

@Entity
data class Student(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0L,

    var name: String = ""
) {
    @OneToMany(mappedBy = "student", cascade = [CascadeType.ALL])
    val enrollments: MutableSet<Enrollment> = mutableSetOf()

    fun addEnrollment(enrollment: Enrollment) {
        enrollments.add(enrollment)
        enrollment.student = this
    }
}










### kotlin/ru/zavanton/demo/entity/Course.kt
package ru.zavanton.demo.entity

import javax.persistence.CascadeType
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.OneToMany

@Entity
data class Course(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0L,

    var name: String = ""
) {
    @OneToMany(mappedBy = "course", cascade = [CascadeType.ALL])
    val enrollments: MutableSet<Enrollment> = mutableSetOf()

    fun addEnrollment(enrollment: Enrollment) {
        enrollments.add(enrollment)
        enrollment.course = this
    }
}










### kotlin/ru/zavanton/demo/entity/Enrollment.kt
package ru.zavanton.demo.entity

import java.util.Date
import javax.persistence.CascadeType
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.ManyToOne
import javax.persistence.Temporal
import javax.persistence.TemporalType

@Entity
data class Enrollment(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0L,

    @ManyToOne(cascade = [CascadeType.ALL])
    @JoinColumn(name = "student_id", referencedColumnName = "id")
    var student: Student? = null,

    @ManyToOne(cascade = [CascadeType.ALL])
    @JoinColumn(name = "course_id", referencedColumnName = "id")
    var course: Course? = null,

    @Temporal(TemporalType.DATE)
    var enrollmentDate: Date = Date()
)
