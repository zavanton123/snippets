# Spring - how to validate REST request? How to create a custom validator? @Constraint, @ConstraintValidator

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










### kotlin/ru/zavanton/demo/repository/InstructorRepository.kt
package ru.zavanton.demo.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.data.Instructor

@Repository
interface InstructorRepository : JpaRepository<Instructor, Long>










### kotlin/ru/zavanton/demo/mapper/InstructorMapper.kt
package ru.zavanton.demo.mapper

import org.springframework.stereotype.Component
import ru.zavanton.demo.data.Instructor
import ru.zavanton.demo.data.InstructorRating
import ru.zavanton.demo.dto.InstructorDTO

@Component
class InstructorMapper {

    fun toEntity(dto: InstructorDTO): Instructor {
        return Instructor(
            id = dto.id,
            name = dto.name,
            rating = mapRatingToEntity(dto.rating)
        )
    }

    fun toDto(entity: Instructor): InstructorDTO {
        return InstructorDTO(
            id = entity.id,
            name = entity.name,
            rating = mapRatingToDto(entity.rating)
        )
    }

    private fun mapRatingToDto(rating: InstructorRating): String {
        return rating.name.lowercase()
    }

    private fun mapRatingToEntity(rating: String): InstructorRating {
        try {
            return InstructorRating.valueOf(rating.uppercase())
        } catch (exception: Exception) {
            // note: we should never reach this exception
            // this situation must be processed earlier by the rating validator
            throw RuntimeException("The rating must have the correct value (low, average, high)!")
        }
    }
}










### kotlin/ru/zavanton/demo/validation/InstructorRatingValidation.kt
package ru.zavanton.demo.validation

import javax.validation.Constraint
import kotlin.reflect.KClass

@Target(
    allowedTargets = [
        AnnotationTarget.TYPE,
        AnnotationTarget.CLASS,
        AnnotationTarget.CONSTRUCTOR,
    ]
)
@Retention(AnnotationRetention.RUNTIME)
@Constraint(validatedBy = [InstructorRatingValidator::class])
annotation class InstructorRatingValidation(
    val message: String = "The rating must be low, average or high",
    val groups: Array<KClass<*>> = [],
    val payload: Array<KClass<*>> = []
)










### kotlin/ru/zavanton/demo/validation/InstructorRatingValidator.kt
package ru.zavanton.demo.validation

import javax.validation.ConstraintValidator
import javax.validation.ConstraintValidatorContext
import ru.zavanton.demo.data.InstructorRating
import ru.zavanton.demo.dto.InstructorDTO

class InstructorRatingValidator : ConstraintValidator<InstructorRatingValidation, InstructorDTO> {

    override fun isValid(
        instructorDTO: InstructorDTO,
        context: ConstraintValidatorContext
    ): Boolean {
        return instructorDTO.rating in InstructorRating.values()
            .map {
                it.name.lowercase()
            }
    }
}










### kotlin/ru/zavanton/demo/data/Instructor.kt
package ru.zavanton.demo.data

import javax.persistence.Entity
import javax.persistence.EnumType
import javax.persistence.Enumerated
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
class Instructor(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0L,

    var name: String = "",

    @Enumerated(EnumType.STRING)
    var rating: InstructorRating = InstructorRating.AVERAGE
) {
    override fun toString(): String {
        return "Instructor(id=$id, name='$name', rating=$rating)"
    }
}










### kotlin/ru/zavanton/demo/data/InstructorRating.kt
package ru.zavanton.demo.data

enum class InstructorRating {
    HIGH,
    AVERAGE,
    LOW,
}










### kotlin/ru/zavanton/demo/controller/InstructorController.kt
package ru.zavanton.demo.controller

import javax.validation.Valid
import javax.validation.ValidationException
import org.springframework.validation.Errors
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.dto.InstructorDTO
import ru.zavanton.demo.service.InstructorService

@RestController
@RequestMapping("/api")
class InstructorController(
    private val instructorService: InstructorService
) {

    @GetMapping("/instructors")
    fun loadInstructor(): List<InstructorDTO> {
        return instructorService.fetchInstructors()
    }

    @PostMapping("/instructors")
    fun createInstructor(
        @Valid @RequestBody instructorDTO: InstructorDTO,
        errors: Errors
    ): InstructorDTO {
        if (errors.hasErrors()) {
            errors.allErrors.forEach {
                throw ValidationException(it.defaultMessage)
            }
        }
        return instructorService.createInstructor(instructorDTO)
    }
}










### kotlin/ru/zavanton/demo/controller/ExceptionDTO.kt
package ru.zavanton.demo.controller

class ExceptionDTO(
    var message: String
)










### kotlin/ru/zavanton/demo/controller/ExceptionAdvice.kt
package ru.zavanton.demo.controller

import javax.validation.ValidationException
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class ExceptionAdvice {

    @ExceptionHandler(ValidationException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    fun processValidationError(exception: ValidationException): ExceptionDTO {
        return ExceptionDTO(exception.message ?: "some validation exception")
    }

    @ExceptionHandler(RuntimeException::class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    fun processRuntimeException(exception: RuntimeException): ExceptionDTO {
        return ExceptionDTO(exception.message ?: "some runtime exception")
    }
}










### kotlin/ru/zavanton/demo/dto/InstructorDTO.kt
package ru.zavanton.demo.dto

import javax.validation.constraints.NotEmpty
import javax.validation.constraints.Size
import ru.zavanton.demo.validation.InstructorRatingValidation

@InstructorRatingValidation
class InstructorDTO(
    var id: Long = 0L,

    @get:NotEmpty(message = "Must not be empty")
    @get:Size(min = 2, max = 5, message = "Must be between 2 and 10")
    var name: String = "",

    var rating: String = ""
)










### kotlin/ru/zavanton/demo/service/InstructorServiceImpl.kt
package ru.zavanton.demo.service

import org.springframework.stereotype.Service
import ru.zavanton.demo.dto.InstructorDTO
import ru.zavanton.demo.mapper.InstructorMapper
import ru.zavanton.demo.repository.InstructorRepository

@Service
class InstructorServiceImpl(
    private val instructorMapper: InstructorMapper,
    private val instructorRepository: InstructorRepository,
) : InstructorService {

    override fun fetchInstructors(): List<InstructorDTO> {
        return instructorRepository.findAll()
            .map {
                instructorMapper.toDto(it)
            }
            .toList()
    }

    override fun createInstructor(instructorDto: InstructorDTO): InstructorDTO {
        val entity = instructorMapper.toEntity(instructorDto)
        val savedInstructor = instructorRepository.save(entity)
        return instructorMapper.toDto(savedInstructor)
    }
}









### kotlin/ru/zavanton/demo/service/InstructorService.kt
package ru.zavanton.demo.service

import ru.zavanton.demo.dto.InstructorDTO

interface InstructorService {

    fun fetchInstructors(): List<InstructorDTO>

    fun createInstructor(instructorDto: InstructorDTO): InstructorDTO
}
