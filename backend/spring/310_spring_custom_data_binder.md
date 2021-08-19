# Spring - How to create a custom data binder?



### resources/application.yml
server:
  port: 8989
springdoc:
  api-docs:
    # the default is /v3/api-docs
    path: /api-docs

  swagger-ui:
    # the default is /swagger-ui.html
    path: /swagger










### kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### kotlin/ru/zavanton/demo/config/WebConfig.kt
package ru.zavanton.demo.config

import org.springframework.context.annotation.Configuration
import org.springframework.format.FormatterRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer
import ru.zavanton.demo.converter.StringToAnimalConverterFactory

@Configuration
class WebConfig : WebMvcConfigurer {

    override fun addFormatters(registry: FormatterRegistry) {
        registry.addConverterFactory(StringToAnimalConverterFactory())
    }
}










### kotlin/ru/zavanton/demo/data/Cat.kt
package ru.zavanton.demo.data

class Cat(val id: Long) : Animal {

    override fun greet(): String {
        return "I am a cat"
    }
}










### kotlin/ru/zavanton/demo/data/Student.kt
package ru.zavanton.demo.data

data class Student(
    val id: Long = 0,
    var name: String = ""
)










### kotlin/ru/zavanton/demo/data/Dog.kt
package ru.zavanton.demo.data

class Dog(val id: Long) : Animal {

    override fun greet(): String {
       return "I am a dog"
    }
}










### kotlin/ru/zavanton/demo/data/Difficulty.kt
package ru.zavanton.demo.data

enum class Difficulty {
    EASY, MEDIUM, HARD
}










### kotlin/ru/zavanton/demo/data/Animal.kt
package ru.zavanton.demo.data

interface Animal {

    fun greet(): String
}










### kotlin/ru/zavanton/demo/controller/HomeController.kt
package ru.zavanton.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.data.Cat
import ru.zavanton.demo.data.Difficulty
import ru.zavanton.demo.data.Dog
import ru.zavanton.demo.data.Student

@RestController
class HomeController {

    private val log = LoggerFactory.getLogger(HomeController::class.java)

    @GetMapping("/data/{student}")
    fun studentDemo(
        @PathVariable("student") student: Student
    ): Student {
        return student
    }

    @GetMapping("/demo/{difficulty}")
    fun difficultyDemo(
        @PathVariable("difficulty") difficulty: Difficulty
    ): String {
        log.info("zavanton - difficulty: $difficulty")
        return "The difficulty is $difficulty"
    }

    @GetMapping("/cat/{id}")
    fun catConverterFactoryDemo(
        @PathVariable("id") cat: Cat
    ): String {
        log.info("zavanton - cat greet: ${cat.greet()}")
        return "The greeting is ${cat.greet()}"
    }

    @GetMapping("/dog/{id}")
    fun dogConverterFactoryDemo(
        @PathVariable("id") dog: Dog
    ): String {
        log.info("zavanton - dog greet: ${dog.greet()}")
        return "The greeting is ${dog.greet()}"
    }
}










### kotlin/ru/zavanton/demo/converter/DifficultyConverter.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component
import ru.zavanton.demo.data.Difficulty

@Component
class DifficultyConverter : Converter<String, Difficulty> {

    override fun convert(source: String): Difficulty {
        return Difficulty.valueOf(source)
    }
}










### kotlin/ru/zavanton/demo/converter/StudentConverter.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component
import ru.zavanton.demo.data.Student

@Component
class StudentConverter : Converter<String, Student> {

    override fun convert(source: String): Student {
        val elements = source.split("-")
        val id = elements[0].toLong()
        val name = elements[1]
        return Student(id = id, name = name)
    }
}










### kotlin/ru/zavanton/demo/converter/StringToAnimalConverterFactory.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.core.convert.converter.ConverterFactory
import org.springframework.stereotype.Component
import ru.zavanton.demo.data.Animal
import ru.zavanton.demo.data.Cat
import ru.zavanton.demo.data.Dog

@Component
class StringToAnimalConverterFactory : ConverterFactory<String, Animal> {

    class MyConverter<T : Animal>(val targetType: Class<T>) : Converter<String, T> {

        override fun convert(source: String): T {
            val id = source.toLong()
            return when {
                targetType == Cat::class.java -> Cat(id) as T
                targetType == Dog::class.java -> Dog(id) as T
                else -> throw RuntimeException("wrong type")
            }
        }
    }

    override fun <T : Animal> getConverter(targetType: Class<T>): Converter<String, T> {
        return MyConverter(targetType)
    }
}
