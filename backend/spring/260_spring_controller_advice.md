# Java Spring - using @ControllerAdvice to handle exceptions



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










### test/kotlin/ru/zavanton/demo/controller/HomeControllerTest.kt
package ru.zavanton.demo.controller

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.mockito.Mockito.`when`
import org.mockito.Mockito.anyLong
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.model
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.view
import org.springframework.test.web.servlet.setup.MockMvcBuilders
import org.springframework.ui.Model
import ru.zavanton.demo.entity.Student
import ru.zavanton.demo.service.StudentService

internal class HomeControllerTest {

    private val studentService = mock(StudentService::class.java)
    private val homeController = HomeController(studentService)
    private val mockMvc = MockMvcBuilders.standaloneSetup(homeController).build()

    @Test
    fun `test home() without mockMvc`() {
        val expected = "index"
        val actual = homeController.home()
        assertEquals(expected, actual)
    }

    @Test
    fun `test home() with mockMvc`() {
        mockMvc.perform(get("/"))
            .andExpect(status().isOk)
            .andExpect(view().name("index"))
    }

    @Test
    fun `test showStudent without mockMvc`() {
        // mock
        val expected = "student"
        val studentId = 0L
        val student = Student()
        val model = mock(Model::class.java)
        `when`(studentService.fetchById(anyLong())).thenReturn(student)

        // action
        val actual = homeController.showStudent(studentId, model)

        // verify
        assertEquals(expected, actual)
        verify(studentService).fetchById(anyLong())
        verify(model).addAttribute("student", student)
    }

    @Test
    fun `test showStudent with mockMvc`() {
        // mock
        val studentId = 0L
        val student = Student()
        `when`(studentService.fetchById(anyLong())).thenReturn(student)

        // action
        mockMvc.perform(get("/students/$studentId"))
            .andExpect(status().isOk)
            .andExpect(model().attributeExists("student"))

        // verify
        verify(studentService).fetchById(anyLong())
    }
}










### test/kotlin/ru/zavanton/demo/service/StudentServiceImplTest.kt
package ru.zavanton.demo.service

import java.util.*
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.mockito.Mockito.`when`
import org.mockito.Mockito.anyLong
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import ru.zavanton.demo.entity.Student
import ru.zavanton.demo.exception.StudentNotFoundException
import ru.zavanton.demo.repository.StudentRepository

internal class StudentServiceImplTest {

    private val studentRepository = mock(StudentRepository::class.java)
    private val studentService = StudentServiceImpl(studentRepository)

    @Test
    fun `test fetchById finds and returns a student`() {
        // mock
        val expected = Student()
        val optional = Optional.of(expected)
        `when`(studentRepository.findById(anyLong())).thenReturn(optional)

        // action
        val actual = studentService.fetchById(anyLong())

        // verify
        assertEquals(expected, actual)
        verify(studentRepository).findById(anyLong())
    }

    @Test
    fun `test fetchById fails to find a student and returns an error`() {
        // mock
        val optional = Optional.empty<Student>()
        `when`(studentRepository.findById(anyLong())).thenReturn(optional)

        // action
        assertThrows<StudentNotFoundException> {
            studentService.fetchById(anyLong())
        }

        // verify
        verify(studentRepository).findById(anyLong())
    }
}










### main/resources/data.sql
insert into student (name, grade) values ('Mike Tyson', 85.5)
insert into student (name, grade) values ('James Bond', 100.0)
insert into student (name, grade) values ('Spider Man', 99.5)










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










### main/resources/templates/error.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Error</title>
</head>
<body>
<h1>Error</h1>
<p th:text="${exception.getMessage()}">Error...</p>
</body>
</html>










### main/resources/templates/index.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Home</title>
</head>
<body>
<h1>Home</h1>
<p th:text="'Hello world'">content...</p>
</body>
</html>










### main/resources/templates/student.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Student</title>
</head>
<body>
<h1>Student</h1>
<p th:text="'Name: ' + ${student.name}">student name</p>
<p th:text="'Grade: ' + ${student.grade}">student grade</p>
</body>
</html>










### main/resources/templates/error404.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Not Found</title>
</head>
<body>
<h1>Not Found</h1>
</body>
</html>










### main/kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
	runApplication<App>(*args)
}










### main/kotlin/ru/zavanton/demo/repository/StudentRepository.kt
package ru.zavanton.demo.repository

import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Student

@Repository
interface StudentRepository : CrudRepository<Student, Long>{
}










### main/kotlin/ru/zavanton/demo/controller/HomeController.kt
package ru.zavanton.demo.controller

import org.springframework.http.HttpStatus
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.servlet.ModelAndView
import ru.zavanton.demo.exception.StudentNotFoundException
import ru.zavanton.demo.service.StudentService

@Controller
class HomeController(
    private val studentService: StudentService
) {

    @GetMapping("", "/")
    fun home(): String {
        return "index"
    }

    @GetMapping("/students/{id}")
    fun showStudent(
        @PathVariable("id") id: Long,
        model: Model
    ): String {
        val student = studentService.fetchById(id)
        model.addAttribute("student", student)
        return "student"
    }

    @ResponseStatus(HttpStatus.NOT_FOUND)
    @ExceptionHandler(StudentNotFoundException::class)
    fun processNotFound(): ModelAndView {
        val modelAndView = ModelAndView()
        modelAndView.viewName = "error404"
        return modelAndView
    }

//    @ResponseStatus(HttpStatus.BAD_REQUEST)
//    @ExceptionHandler(NumberFormatException::class)
//    fun processNumberFormatException(exception: Exception): ModelAndView {
//        log.error("zavanton - number format exception is processed")
//        val modelAndView = ModelAndView()
//        modelAndView.viewName = "error"
//        modelAndView.addObject("exception", exception)
//        return modelAndView
//    }
}










### main/kotlin/ru/zavanton/demo/controller/ControllerExceptionHandler.kt
package ru.zavanton.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ControllerAdvice
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.servlet.ModelAndView

@ControllerAdvice
class ControllerExceptionHandler {

    private val log = LoggerFactory.getLogger(ControllerExceptionHandler::class.java)

    @ResponseStatus(HttpStatus.BAD_REQUEST)
    @ExceptionHandler(NumberFormatException::class)
    fun processNumberFormatException(exception: Exception): ModelAndView {
        log.error("zavanton - number format exception is processed")
        val modelAndView = ModelAndView()
        modelAndView.viewName = "error"
        modelAndView.addObject("exception", exception)
        return modelAndView
    }
}










### main/kotlin/ru/zavanton/demo/exception/StudentNotFoundException.kt
package ru.zavanton.demo.exception

import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@ResponseStatus(HttpStatus.NOT_FOUND)
class StudentNotFoundException : RuntimeException() {
}










### main/kotlin/ru/zavanton/demo/entity/Student.kt
package ru.zavanton.demo.entity

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
class Student(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0,
    var name: String = "",
    var grade: Double = 0.0
)










### main/kotlin/ru/zavanton/demo/service/StudentServiceImpl.kt
package ru.zavanton.demo.service

import org.springframework.stereotype.Service
import ru.zavanton.demo.entity.Student
import ru.zavanton.demo.exception.StudentNotFoundException
import ru.zavanton.demo.repository.StudentRepository

@Service
class StudentServiceImpl(
    private val studentRepository: StudentRepository
) : StudentService {

    override fun fetchById(id: Long): Student {
        val optional = studentRepository.findById(id)
        return if (optional.isPresent) {
            optional.get()
        } else {
            throw StudentNotFoundException()
        }
    }
}










### main/kotlin/ru/zavanton/demo/service/StudentService.kt
package ru.zavanton.demo.service

import ru.zavanton.demo.entity.Student

interface StudentService {

    fun fetchById(id: Long): Student
}
