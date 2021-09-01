# Spring - Data, Mapping a single entity to many tables (@SecondaryTable, @PrimaryKeyJoinColumn)



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










### kotlin/ru/zavanton/demo/repository/MealRepository.kt
package ru.zavanton.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Meal

@Repository
interface MealRepository : JpaRepository<Meal, Long> {
}










### kotlin/ru/zavanton/demo/runner/DataInitializer.kt
package ru.zavanton.demo.runner

import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component
import ru.zavanton.demo.entity.Meal
import ru.zavanton.demo.repository.MealRepository

@Component
class DataInitializer(
    private val mealRepository: MealRepository
) : CommandLineRunner {

    override fun run(vararg args: String) {
        val meal = Meal(name = "Breakfast", description = "peanuts", weight = 10.5)
        mealRepository.save(meal)
    }
}










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class MyController {

    @GetMapping("")
    fun home(): String {
        return "ok"
    }
}










### kotlin/ru/zavanton/demo/entity/Meal.kt
package ru.zavanton.demo.entity

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.PrimaryKeyJoinColumn
import javax.persistence.SecondaryTable
import javax.persistence.Table

@Entity
@Table(name = "meal")
@SecondaryTable(name = "allergens", pkJoinColumns = [PrimaryKeyJoinColumn(name = "meal_id")])
data class Meal(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0L,

    var name: String = "",

    @Column(table = "allergens")
    var description: String = "",

    @Column(table = "allergens")
    var weight: Double
)
