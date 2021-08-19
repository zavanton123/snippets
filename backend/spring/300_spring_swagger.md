# Spring - using Open Api (Swagger)





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










### kotlin/ru/zavanton/demo/SwaggerDemoApplication.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class SwaggerDemoApplication

fun main(args: Array<String>) {
	runApplication<SwaggerDemoApplication>(*args)
}










### kotlin/ru/zavanton/demo/data/Student.kt
package ru.zavanton.demo.data

data class Student(
    val id: Long = 0,
    var name: String = ""
)










### kotlin/ru/zavanton/demo/controller/HomeController.kt
package ru.zavanton.demo.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.ArraySchema
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.data.Student

@RestController
class HomeController {

    @GetMapping("")
    fun home(): Student {
        return Student(1L, "Mike")
    }

    @Operation(summary = "Print hello world")
    @ApiResponses(value = [
        ApiResponse(responseCode = "200", description = "Some info here...", content = [
            (Content(mediaType = "application/json", array = (
                    ArraySchema(schema = Schema(implementation = Student::class)))))]),
        ApiResponse(responseCode = "400", description = "Bad request", content = [Content()]),
        ApiResponse(responseCode = "404", description = "Did not find any...", content = [Content()])]
    )
    @GetMapping("/api/hello")
    fun hello(): String {
        return "hello world"
    }
}
