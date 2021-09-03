# Spring - custom @Qualifier for dependency injection


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










### kotlin/ru/zavanton/demo/repository/PersonRepository.kt
package ru.zavanton.demo.repository

interface PersonRepository {

    fun hello(): String
}










### kotlin/ru/zavanton/demo/repository/StudentRepository.kt
package ru.zavanton.demo.repository

import org.springframework.stereotype.Repository
import ru.zavanton.demo.repository.qualifers.StudentQualifier

@Repository
@StudentQualifier
class StudentRepository : PersonRepository {

    override fun hello(): String {
        return "student hello"
    }
}










### kotlin/ru/zavanton/demo/repository/ProfessorRepository.kt
package ru.zavanton.demo.repository

import org.springframework.stereotype.Repository
import ru.zavanton.demo.repository.qualifers.ProfessorQualifier

@Repository
@ProfessorQualifier
class ProfessorRepository : PersonRepository {

    override fun hello(): String {
        return "professor hello"
    }
}










### kotlin/ru/zavanton/demo/repository/qualifers/ProfessorQualifier.kt
package ru.zavanton.demo.repository.qualifers

import org.springframework.beans.factory.annotation.Qualifier

@Qualifier("professor")
@Target(
    AnnotationTarget.FIELD,
    AnnotationTarget.TYPE_PARAMETER,
    AnnotationTarget.VALUE_PARAMETER,
    AnnotationTarget.CLASS,
    AnnotationTarget.TYPE,
    AnnotationTarget.CONSTRUCTOR,
    AnnotationTarget.ANNOTATION_CLASS,
)
@Retention(AnnotationRetention.RUNTIME)
annotation class ProfessorQualifier










### kotlin/ru/zavanton/demo/repository/qualifers/StudentQualifier.kt
package ru.zavanton.demo.repository.qualifers

import org.springframework.beans.factory.annotation.Qualifier

@Qualifier("student")
@Target(
    AnnotationTarget.FIELD,
    AnnotationTarget.TYPE_PARAMETER,
    AnnotationTarget.VALUE_PARAMETER,
    AnnotationTarget.CLASS,
    AnnotationTarget.TYPE,
    AnnotationTarget.CONSTRUCTOR,
    AnnotationTarget.ANNOTATION_CLASS,
)
@Retention(AnnotationRetention.RUNTIME)
annotation class StudentQualifier










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.repository.PersonRepository
import ru.zavanton.demo.repository.qualifers.ProfessorQualifier

@RestController
class MyController(
    @ProfessorQualifier
    private val personRepository: PersonRepository
) {
    @GetMapping("")
    fun hello(): String {
        return personRepository.hello()
    }
}
