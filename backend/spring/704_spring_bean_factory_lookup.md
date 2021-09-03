# Spring - bean factory, @Lookup



### resources/application.yml
server:
  port: 9999










### kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### kotlin/ru/zavanton/demo/data/StudentFactory.kt
package ru.zavanton.demo.data

import org.springframework.beans.factory.annotation.Lookup
import org.springframework.stereotype.Component

@Component
class StudentFactory {

    @Lookup
    fun createStudent(): Student? {
       return null
    }
}










### kotlin/ru/zavanton/demo/data/Student.kt
package ru.zavanton.demo.data

import org.springframework.context.annotation.Scope
import org.springframework.stereotype.Component

@Component
@Scope("prototype")
class Student(
    var id: Double? = Math.random()
)










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.data.StudentFactory

@RestController
class MyController(
    private val studentFactoryOne: StudentFactory,
    private val studentFactoryTwo: StudentFactory,
) {
    private val log = LoggerFactory.getLogger(MyController::class.java)

    @GetMapping("")
    fun hello(): String {
        val studentOne = studentFactoryOne.createStudent()
            ?: throw RuntimeException("No student is injected")

        val studentTwo = studentFactoryTwo.createStudent()
            ?: throw RuntimeException("No student is injected")

        log.info("zavanton - are factories the same? - ${studentFactoryOne === studentFactoryTwo}")

        log.info("zavanton - student one: ${studentOne.id}")
        log.info("zavanton - student two: ${studentTwo.id}")

        return "hello"
    }
}
