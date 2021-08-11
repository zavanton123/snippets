# Using Thymeleaf templates with Spring


### kotlin/com/zavanton/web/App.kt
package com.zavanton.web

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}





### kotlin/com/zavanton/web/data/Student.kt
package com.zavanton.web.data

data class Student(
val firstName: String,
val lastName: String
) {

    fun sayHello(): String = "Hello from student $firstName $lastName"
}










### kotlin/com/zavanton/web/controller/WebController.kt
package com.zavanton.web.controller

import com.zavanton.web.data.Student
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestMethod
import org.springframework.web.servlet.ModelAndView

@Controller
class WebController {

    @GetMapping("/")
    fun home(model: Model): String {
        model.addAttribute("username", "zavanton")
        return "home"
    }

    @RequestMapping("/student", method = [RequestMethod.GET])
    fun student(model: Model): String {
        val student = Student("Mike", "Tyson")
        model.addAttribute("student", student)
        return "student"
    }

    @RequestMapping("/info", method = [RequestMethod.GET])
    fun info(model: Model): ModelAndView {
        val student = Student("Mike", "Tyson")
        return ModelAndView("student", mapOf("student" to student))
    }

}
















### resources/messages.properties
localized.hello=Hello!
localized.good_bye=Good Bye, {0}!


### resources/messages_ru.properties
localized.hello=Привет!
localized.good_bye=Прощай, {0}!


### resources/messages_ru_RU.properties
localized.hello=Привет!
localized.good_bye=Прощай, {0}!






### resources/application.yml
server:
  port: 9999




















### resources/templates/student.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Student</title>
</head>
<body>
<h1>Student</h1>

<p th:text="${student.firstName} + ' is ok!'">Student first name...</p>

<p th:text="${student.getLastName()}">Student last name...</p>

<p th:text="${student.sayHello()}">Hello from student</p>

</body>
</html>










### resources/templates/home.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Home</title>
</head>
<body>
<h1>Home</h1>
<p th:text="'Hello, ' + ${username} + '! Glad to meet you!'">Hello user</p>

<p th:text="#{localized.hello}">Localized hello here...</p>

<p th:text="#{localized.good_bye('James')}">Localized good bye here...</p>

<p th:text="#{localized.good_bye(${username})}">Localized good bye here...</p>

</body>
</html>





















