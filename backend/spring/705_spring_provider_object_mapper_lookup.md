# Spring - Inject prototype-scoped bean into a singleton-scoped bean (@Lookup, Provider, ObjectFactory)



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

import javax.inject.Provider
import org.springframework.beans.factory.ObjectFactory
import org.springframework.beans.factory.annotation.Lookup
import org.springframework.context.ApplicationContext
import org.springframework.context.ApplicationContextAware
import org.springframework.stereotype.Component

// Note: the problem is we want to inject a prototype-scoped bean Student
// into a singleton-scoped bean StudentFactory.
// There are some solutions here.
@Component
class StudentFactory(
    private val provider: Provider<Student>,
    private val objectFactory: ObjectFactory<Student>
) : ApplicationContextAware {

    private lateinit var applicationContext: ApplicationContext

    // note: bad choice
    // i.e. we should not manage the DI manually
    fun createStudentBad(): Student {
        return applicationContext.getBean("student", Student::class.java)
    }

    // note: bad choice
    // i.e. we should not manage the DI manually
    override fun setApplicationContext(applicationContext: ApplicationContext) {
        this.applicationContext = applicationContext
    }

    // it is an ok solution (i.e. 'method injection')
    @Lookup
    fun createStudent(): Student? {
        return null
    }

    // it is an ok solution (i.e. via javax Provider)
    fun provideStudent(): Student {
        return provider.get()
    }

    // it is an ok solution (i.e. via ObjectFactory)
    fun factoryStudent(): Student {
        return objectFactory.`object`
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
    private val studentFactory: StudentFactory,
    private val studentFactoryClone: StudentFactory,
) {
    private val log = LoggerFactory.getLogger(MyController::class.java)

    @GetMapping("/bad")
    fun demoApplicationContextAware(): String {
        val student = studentFactory.createStudentBad()
        log.info("zavanton - bad student: ${student.id}")
        return "bad"
    }

    @GetMapping("/lookup")
    fun demoLookup(): String {
        val studentOne = studentFactory.createStudent()
            ?: throw RuntimeException("No student is injected")

        val studentTwo = studentFactoryClone.createStudent()
            ?: throw RuntimeException("No student is injected")

        log.info("zavanton - are factories the same? - ${studentFactory === studentFactoryClone}")
        log.info("zavanton - student one: ${studentOne.id}")
        log.info("zavanton - student two: ${studentTwo.id}")
        return "hello"
    }

    @GetMapping("/provider")
    fun demoProvider(): String {
        val student = studentFactory.provideStudent()
        log.info("zavanton - provider student: ${student.id}")
        return "provider"
    }

    @GetMapping("/factory")
    fun demoFactory(): String {
        val student = studentFactory.factoryStudent()
        log.info("zavanton - factory student: ${student.id}")
        return "factory"
    }
}
