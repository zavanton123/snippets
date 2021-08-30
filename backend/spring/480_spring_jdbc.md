# Spring - JDBC, JdbcTemplate, NamedParameterJdbcTemplate, RowMapper, DataSource



### resources/schema.sql
create table student
(
    id   integer      not null auto_increment,
    name varchar(100) not null,
    primary key (id)
);










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










### kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
	runApplication<App>(*args)
}










### kotlin/ru/zavanton/demo/mapper/StudentRowMapper.kt
package ru.zavanton.demo.mapper

import java.sql.ResultSet
import org.springframework.jdbc.core.RowMapper
import org.springframework.stereotype.Component
import ru.zavanton.demo.entity.Student

@Component
class StudentRowMapper : RowMapper<Student> {

    override fun mapRow(rs: ResultSet, rowNum: Int): Student {
        return Student(
            id = rs.getLong("id"),
            name = rs.getString("name")
        )
    }
}










### kotlin/ru/zavanton/demo/dao/StudentDao.kt
package ru.zavanton.demo.dao

import javax.sql.DataSource
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.core.namedparam.BeanPropertySqlParameterSource
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate
import org.springframework.jdbc.core.simple.SimpleJdbcInsert
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Student
import ru.zavanton.demo.mapper.StudentRowMapper

@Repository
class StudentDao(
    private val jdbcTemplate: JdbcTemplate,
    private val namedTemplate: NamedParameterJdbcTemplate,
    private val studentRowMapper: StudentRowMapper,
    private val dataSource: DataSource,
) {

    fun findCount(): Int {
        return jdbcTemplate.queryForObject(
            "select count(*) from student", Int::class.java
        ) ?: 0
    }

    fun save(student: Student) {
        jdbcTemplate.update("insert into student (name) values (?)", student.name)
    }

    fun saveViaNamed(student: Student) {
        val params = MapSqlParameterSource().addValue("name", student.name)
        namedTemplate.update("insert into student (name) values :name", params)
    }

    fun findCountViaNamed(student: Student): Int {
        return namedTemplate.queryForObject(
            "select count(*) from student where name = :name",
            BeanPropertySqlParameterSource(student),
            Int::class.java
        )
            ?: 0
    }

    fun findById(id: Long): Student {
        return jdbcTemplate.queryForObject(
            "select * from student where id = ?",
            arrayOf(id),
            studentRowMapper
        ) ?: throw RuntimeException("Student wit id $id not found")
    }

    fun insertWithSimpleJdbcInsert(student: Student): Int {
        val simpleJdbcInsert = SimpleJdbcInsert(dataSource)
            .withTableName("student")
            .usingGeneratedKeyColumns("id")
        val params = mutableMapOf<String, Any>();
        params["id"] = student.id
        params["name"] = student.name
        return simpleJdbcInsert.executeAndReturnKey(params).toInt()
    }
}










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.dao.StudentDao
import ru.zavanton.demo.entity.Student

@RestController
class MyController(
    private val studentDao: StudentDao,
) {

    @PostMapping("/students/create")
    fun create(
        @RequestBody request: CreateStudentRequest
    ): ResponseEntity<Any> {
        val student = Student(name = request.name)
        studentDao.save(student)
        return ResponseEntity
            .status(HttpStatus.CREATED)
            .build()
    }

    @PostMapping("/students/create/named")
    fun createViaNamed(
        @RequestBody request: CreateStudentRequest
    ): ResponseEntity<String> {
        val student = Student(name = request.name)
        studentDao.saveViaNamed(student)
        return ResponseEntity
            .status(HttpStatus.CREATED)
            .body("Created via named")
    }

    @GetMapping("/students/count")
    fun count(): String {
        val count = studentDao.findCount()
        return "Count: $count"
    }

    @GetMapping("/students/count/{name}")
    fun countViaNamed(
        @PathVariable("name") name: String
    ): String {
        val student = Student(name = name)
        val count = studentDao.findCountViaNamed(student)
        return "Count for $name: $count"
    }

    @GetMapping("/students/find/{id}")
    fun demoRowMapper(
        @PathVariable("id") id: Long
    ): String {
        val student = studentDao.findById(id)
        return "Student: ${student.name}"
    }

    @PostMapping("/simple")
    fun insertWithSimple(): String {
        val student = Student(name = "Mike")
        val id = studentDao.insertWithSimpleJdbcInsert(student)
        return "Inserted student id: $id"
    }
}










### kotlin/ru/zavanton/demo/controller/CreateStudentRequest.kt
package ru.zavanton.demo.controller

data class CreateStudentRequest(
    val name: String
)










### kotlin/ru/zavanton/demo/entity/Student.kt
package ru.zavanton.demo.entity

data class Student(
    val id: Long = 0L,
    var name: String = ""
)
