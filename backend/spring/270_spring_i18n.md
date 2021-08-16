# Java Spring - internationalisation (messages.properties)





### test/kotlin/ru/zavanton/demo/AppTests.kt
package ru.zavanton.demo

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class AppTests {

//	@Test
//	fun contextLoads() {
//	}

}










### test/kotlin/ru/zavanton/demo/controller/StudentControllerTest.kt
package ru.zavanton.demo.controller

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers
import org.springframework.test.web.servlet.setup.MockMvcBuilders
import org.springframework.ui.Model
import ru.zavanton.demo.entity.Student
import ru.zavanton.demo.service.StudentService

internal class StudentControllerTest {

    private val studentService = Mockito.mock(StudentService::class.java)
    private val studentController = StudentController(studentService)
    private val mockMvc = MockMvcBuilders.standaloneSetup(studentController).build()

    @Test
    fun `test showStudent without mockMvc`() {
        // mock
        val expected = "students/student_details"
        val studentId = 0L
        val student = Student()
        val model = Mockito.mock(Model::class.java)
        Mockito.`when`(studentService.fetchById(Mockito.anyLong())).thenReturn(student)

        // action
        val actual = studentController.showStudent(studentId, model)

        // verify
        assertEquals(expected, actual)
        Mockito.verify(studentService).fetchById(Mockito.anyLong())
        Mockito.verify(model).addAttribute("student", student)
    }

    @Test
    fun `test showStudent with mockMvc`() {
        // mock
        val studentId = 0L
        val student = Student()
        Mockito.`when`(studentService.fetchById(Mockito.anyLong())).thenReturn(student)

        // action
        mockMvc.perform(MockMvcRequestBuilders.get("/students/$studentId"))
            .andExpect(MockMvcResultMatchers.status().isOk)
            .andExpect(MockMvcResultMatchers.model().attributeExists("student"))

        // verify
        Mockito.verify(studentService).fetchById(Mockito.anyLong())
    }
}









### test/kotlin/ru/zavanton/demo/controller/HomeControllerTest.kt
package ru.zavanton.demo.controller

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.view
import org.springframework.test.web.servlet.setup.MockMvcBuilders

internal class HomeControllerTest {

    private val homeController = HomeController()
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
import ru.zavanton.demo.converter.StudentCommandToEntityConverter
import ru.zavanton.demo.converter.StudentEntityToCommandConverter
import ru.zavanton.demo.entity.Student
import ru.zavanton.demo.exception.StudentNotFoundException
import ru.zavanton.demo.repository.StudentRepository

internal class StudentServiceImplTest {

    private val studentRepository = mock(StudentRepository::class.java)
    private val studentToEntityConverter = mock(StudentCommandToEntityConverter::class.java)
    private val studentToCommandConverter = mock(StudentEntityToCommandConverter::class.java)
    private val studentService = StudentServiceImpl(
        studentRepository,
        studentToEntityConverter,
        studentToCommandConverter
    )

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










### main/resources/messages_en_US.properties
custom.title=Hello world










### main/resources/messages_ru_RU.properties
custom.title=Привет мир










### main/resources/data.sql
insert into student (name, grade) values ('Mike Tyson', 4.5)
insert into student (name, grade) values ('James Bond', 4.9)
insert into student (name, grade) values ('Spider Man', 3.7)










### main/resources/messages.properties
custom.title=Hello world










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










### main/resources/messages_ru.properties
custom.title=Привет мир










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










### main/resources/templates/students/new_student.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Create a New Student</title>
</head>
<body>
<h1>Create a New Student</h1>

<form th:action="@{/students/create}" method="post">
    <input type="hidden" th:field="${studentCommand.id}"/>

    <label>Name:</label><br/>
    <input type="text" th:field="${studentCommand.name}"/><br/>

    <label>Grade:</label><br/>
    <input type="number" th:field="${studentCommand.grade}"/><br/>

    <input type="submit" value="Save"/><br/>
</form>

</body>
</html>










### main/resources/templates/students/all_students.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>All Students</title>
</head>
<body>
<h1>All Students</h1>

<p th:text="#{custom.title}">hello world here...</p>

</body>
</html>










### main/resources/templates/students/student_details.html
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










### main/kotlin/ru/zavanton/demo/command/StudentCommand.kt
package ru.zavanton.demo.command

import javax.validation.constraints.DecimalMax
import javax.validation.constraints.DecimalMin
import javax.validation.constraints.Size


data class StudentCommand(
    var id: Long = 0L,

    @Size(message = "The name must be of the correct size", min = 2, max = 10)
    var name: String = "",

    @DecimalMin("2.0")
    @DecimalMax("5.0")
    var grade: Double = 0.0
)










### main/kotlin/ru/zavanton/demo/controller/StudentController.kt
package ru.zavanton.demo.controller

import javax.validation.Valid
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.validation.BindingResult
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.ModelAttribute
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.servlet.ModelAndView
import ru.zavanton.demo.command.StudentCommand
import ru.zavanton.demo.exception.StudentNotFoundException
import ru.zavanton.demo.service.StudentService

@Controller
class StudentController(
    private val studentService: StudentService
) {

    private val log = LoggerFactory.getLogger(StudentController::class.java)

    @GetMapping("/students")
    fun showAllStudents(): String {
        return "students/all_students"
    }

    @GetMapping("/students/{id}")
    fun showStudent(
        @PathVariable("id") id: Long,
        model: Model
    ): String {
        val student = studentService.fetchById(id)
        model.addAttribute("student", student)
        return "students/student_details"
    }

    @GetMapping("/students/new")
    fun showNewStudentForm(
        model: Model
    ): String {
        val studentCommand = StudentCommand()
        model.addAttribute("studentCommand", studentCommand)
        return "students/new_student"
    }

    @PostMapping("/students/create")
    fun processNewStudentForm(
        @Valid @ModelAttribute studentCommand: StudentCommand,
        bindingResult: BindingResult,
        model: Model
    ): String {
        log.info("zavanton - processNewStudentForm")

        if (bindingResult.hasErrors()) {
            log.info("zavanton - some errors")
            bindingResult.allErrors.forEach {
                log.error(it.toString())
            }
            return "students/new_student"
        } else {
            log.info("zavanton - no errors")
        }

        val savedStudentCommand = studentService.saveStudentCommand(studentCommand)
        val studentId = savedStudentCommand.id
        return "redirect:/students/$studentId"
    }

    @ResponseStatus(HttpStatus.NOT_FOUND)
    @ExceptionHandler(StudentNotFoundException::class)
    fun processNotFound(): ModelAndView {
        val modelAndView = ModelAndView()
        modelAndView.viewName = "error404"
        return modelAndView
    }
}









### main/kotlin/ru/zavanton/demo/controller/HomeController.kt
package ru.zavanton.demo.controller

import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.GetMapping

@Controller
class HomeController {

    @GetMapping("", "/")
    fun home(): String {
        return "index"
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










### main/kotlin/ru/zavanton/demo/converter/StudentConverter.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component
import ru.zavanton.demo.command.StudentCommand
import ru.zavanton.demo.entity.Student

@Component
class StudentEntityToCommandConverter : Converter<Student, StudentCommand> {

    override fun convert(source: Student): StudentCommand {
        return StudentCommand(source.id, source.name, source.grade)
    }
}

@Component
class StudentCommandToEntityConverter : Converter<StudentCommand, Student> {

    override fun convert(source: StudentCommand): Student {
        return Student(source.id, source.name, source.grade)
    }
}










### main/kotlin/ru/zavanton/demo/service/StudentServiceImpl.kt
package ru.zavanton.demo.service

import org.springframework.stereotype.Service
import ru.zavanton.demo.command.StudentCommand
import ru.zavanton.demo.converter.StudentCommandToEntityConverter
import ru.zavanton.demo.converter.StudentEntityToCommandConverter
import ru.zavanton.demo.entity.Student
import ru.zavanton.demo.exception.StudentNotFoundException
import ru.zavanton.demo.repository.StudentRepository

@Service
class StudentServiceImpl(
    private val studentRepository: StudentRepository,
    private val studentToEntityConverter: StudentCommandToEntityConverter,
    private val studentToCommandConverter: StudentEntityToCommandConverter
) : StudentService {

    override fun fetchById(id: Long): Student {
        val optional = studentRepository.findById(id)
        return if (optional.isPresent) {
            optional.get()
        } else {
            throw StudentNotFoundException()
        }
    }

    override fun saveStudentCommand(studentCommand: StudentCommand): StudentCommand {
        val studentEntity = studentToEntityConverter.convert(studentCommand)
        val savedStudentEntity = studentRepository.save(studentEntity)
        return studentToCommandConverter.convert(savedStudentEntity)
    }
}










### main/kotlin/ru/zavanton/demo/service/StudentService.kt
package ru.zavanton.demo.service

import ru.zavanton.demo.command.StudentCommand
import ru.zavanton.demo.entity.Student

interface StudentService {

    fun fetchById(id: Long): Student

    fun saveStudentCommand(studentCommand: StudentCommand): StudentCommand
}
