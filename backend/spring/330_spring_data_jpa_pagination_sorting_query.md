# Spring - Data JPA (@Query, pagination and sorting, PageRequest.of(), Sort.by())





### test/kotlin/com/evolunta/demo/AppTests.kt
package com.evolunta.demo

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class AppTests {

	@Test
	fun contextLoads() {
	}

}










### test/kotlin/com/evolunta/demo/repository/TaskRepositoryTest.kt
package com.evolunta.demo.repository

import com.evolunta.demo.data.Task
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest

@DataJpaTest
class TaskRepositoryTest {

    @Autowired
    lateinit var taskRepository: TaskRepository

    @Test
    fun `test FetchByNameMatches returns a task`() {
        // mock
        val target = "High"
        val name = "High Priority Task"
        val task = Task(name = name)
        val savedTask = taskRepository.save(task)

        // action
        val result = taskRepository.fetchByNameMatches(target)

        // verify
        assertThat(result).contains(savedTask)
    }

    @Test
    fun `test FetchByNameMatches does not return a task`() {
        // mock
        val target = "Low"
        val name = "High Priority Task"
        val task = Task(name = name)
        val savedTask = taskRepository.save(task)

        // action
        val result = taskRepository.fetchByNameMatches(target)

        // verify
        assertThat(result).doesNotContain(savedTask)
    }
}










### test/kotlin/com/evolunta/demo/repository/StudentRepositoryTest.kt
package com.evolunta.demo.repository

import com.evolunta.demo.data.Student
import java.time.LocalDate
import org.hamcrest.CoreMatchers.hasItems
import org.hamcrest.CoreMatchers.not
import org.hamcrest.MatcherAssert.assertThat
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest

@DataJpaTest
internal class StudentRepositoryTest {

    @Autowired
    lateinit var studentRepository: StudentRepository

    @Test
    fun `test findById returns a student`() {
        // mock
        val id = 0L
        val name = "Mike"
        val student = Student(id = id, name = name)
        val savedStudent = studentRepository.save(student)

        // action
        val optional = studentRepository.findById(savedStudent.id)
        val actualStudent = optional.get()

        // verify
        assertEquals(savedStudent, actualStudent)
    }

    @Test
    fun findByName() {
        // mock
        val name = "Mike"
        val student = Student(name = name)
        studentRepository.save(student)

        // action
        val actual = studentRepository.findByName(name)

        // verify
        assertEquals(name, actual.get().name)
    }

    @Test
    fun findByRegistrationBetween() {
        // mock
        val start = LocalDate.now().minusYears(1)
        val end = LocalDate.now().plusYears(1)
        val student1 = Student(registration = LocalDate.now())
        val student2 = Student(registration = LocalDate.now().plusDays(1))
        val student3 = Student(registration = LocalDate.now().plusYears(2))
        val savedStudent1 = studentRepository.save(student1)
        val savedStudent2 = studentRepository.save(student2)
        val savedStudent3 = studentRepository.save(student3)

        // action
        val list = studentRepository.findByRegistrationBetween(start, end)

        // verify
        assertThat(list, hasItems(savedStudent1, savedStudent2))
        assertThat(list, not(hasItems(savedStudent3)))
    }
}










### test/kotlin/com/evolunta/demo/repository/ProjectRepositoryTest.kt
package com.evolunta.demo.repository

import com.evolunta.demo.data.Project
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort

@SpringBootTest
class ProjectRepositoryTest {

    @Autowired
    lateinit var projectRepository: ProjectRepository

    @BeforeEach
    fun setup() {
        projectRepository.save(Project(name = "Project B"))
        projectRepository.save(Project(name = "Project A"))
        projectRepository.save(Project(name = "Project D"))
        projectRepository.save(Project(name = "Project C"))
        projectRepository.save(Project(name = "Project A"))
    }

    @Test
    fun `test pagination`() {
        // action
        val page = projectRepository.findAll(PageRequest.of(0, 2))

        // verify
        assertThat(page.content).hasSize(2)
    }

    @Test
    fun `test sorting`() {
        // action
        val retrieved = projectRepository.findAll(Sort.by(Sort.Order.asc("name")))
        val sorted = retrieved.sortedBy { it.name }

        // verify
        assertEquals(sorted, retrieved)
    }

    @Test
    fun `test pagination and sorting`() {
        // action
        val retrieved = projectRepository.findAll(
            PageRequest.of(0, 2, Sort.by(Sort.Order.asc("name")))
        )

        // verify
        assertThat(retrieved.content).hasSize(2)
    }
}









### main/resources/application.yml
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










### main/kotlin/com/evolunta/demo/App.kt
package com.evolunta.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
	runApplication<App>(*args)
}










### main/kotlin/com/evolunta/demo/repository/ProjectRepository.kt
package com.evolunta.demo.repository

import com.evolunta.demo.data.Project
import java.time.LocalDate
import java.util.Optional
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface ProjectRepository : JpaRepository<Project, Long> {

    fun findByName(name: String): Optional<Project>

    fun findByDateCreatedBetween(start: LocalDate, end: LocalDate): List<Project>
}










### main/kotlin/com/evolunta/demo/repository/TaskRepository.kt
package com.evolunta.demo.repository

import com.evolunta.demo.data.Task
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface TaskRepository : JpaRepository<Task, Long> {

    @Query("select t from Task t where t.name like %?1%")
    fun fetchByNameMatches(name: String): List<Task>
}










### main/kotlin/com/evolunta/demo/repository/StudentRepository.kt
package com.evolunta.demo.repository

import com.evolunta.demo.data.Student
import java.time.LocalDate
import java.util.Optional
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface StudentRepository : JpaRepository<Student, Long> {

    fun findByName(name: String): Optional<Student>

    fun findByRegistrationBetween(start: LocalDate, end: LocalDate): List<Student>
}










### main/kotlin/com/evolunta/demo/data/Student.kt
package com.evolunta.demo.data

import java.time.LocalDate
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
data class Student(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,

    @Column(name = "full_name")
    var name: String = "",

    @Column(name = "registration_date")
    var registration: LocalDate = LocalDate.now(),
)










### main/kotlin/com/evolunta/demo/data/Task.kt
package com.evolunta.demo.data

import java.time.LocalDate
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
data class Task(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,

    var name: String = "",

    var description: String = "",

    var dateCreated: LocalDate = LocalDate.now(),

    var dueDate: LocalDate = LocalDate.now(),

    var status: TaskStatus = TaskStatus.UNASSIGNED
)










### main/kotlin/com/evolunta/demo/data/TaskStatus.kt
package com.evolunta.demo.data

enum class TaskStatus {
    UNASSIGNED,
    ASSIGNED,
    IN_PROGRESS,
    COMPLETE,
}










### main/kotlin/com/evolunta/demo/data/Project.kt
package com.evolunta.demo.data

import java.time.LocalDate
import javax.persistence.CascadeType
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.OneToMany

@Entity
data class Project(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,

    var name: String = "",

    var dateCreated: LocalDate = LocalDate.now(),
) {

    @OneToMany(fetch = FetchType.EAGER, cascade = [CascadeType.ALL])
    @JoinColumn(name = "project_id")
    val tasks: Set<Task> = mutableSetOf()
}










### main/kotlin/com/evolunta/demo/controller/MyController.kt
package com.evolunta.demo.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class MyController {

    @GetMapping("/")
    fun home(): String {
        return "home"
    }
}
