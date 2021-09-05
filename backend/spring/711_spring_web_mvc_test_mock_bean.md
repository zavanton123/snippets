# Spring - Testing, How to test controller while mocking its dependencies? (@WebMvcTest and @MockBean)



### test/kotlin/ru/zavanton/demo/AppTests.kt
package ru.zavanton.demo

import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class AppTests {

    @Test
    fun test() {
        assertFalse(false)
    }
}










### test/kotlin/ru/zavanton/demo/controller/MyControllerTest.kt
package ru.zavanton.demo.controller

import org.junit.jupiter.api.Test
import org.mockito.Mockito.`when`
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import ru.zavanton.demo.data.Company
import ru.zavanton.demo.service.CompanyService

@WebMvcTest(controllers = [MyController::class])
internal class MyControllerTest {

    @Autowired
    lateinit var mvc: MockMvc

    @MockBean
    lateinit var companyService: CompanyService

    @Test
    fun loadCompany() {
        // mock
        val id = 0L
        val name = "Facebook"
        val company = Company(id, name)
        `when`(companyService.fetchCompany(id)).thenReturn(company)

        // action and verify
        mvc.perform(get("/companies/$id"))
            .andExpect(jsonPath("$.id").value(id.toInt()))
            .andExpect(jsonPath("$.name").value(name))
    }
}










### main/resources/application.yml
server:
  port: 3000










### main/kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### main/kotlin/ru/zavanton/demo/data/Company.kt
package ru.zavanton.demo.data

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
class Company(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0L,
    var name: String = ""
)










### main/kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.data.Company
import ru.zavanton.demo.service.CompanyService

@RestController
class MyController(
    private val companyService: CompanyService
) {
    @GetMapping("/companies/{id}")
    @ResponseStatus(HttpStatus.OK)
    fun loadCompany(
        @PathVariable id: Long
    ): Company {
        return companyService.fetchCompany(id)
    }
}










### main/kotlin/ru/zavanton/demo/service/CompanyServiceImpl.kt
package ru.zavanton.demo.service

import org.springframework.stereotype.Service
import ru.zavanton.demo.data.Company

@Service
class CompanyServiceImpl : CompanyService {

    override fun fetchCompany(id: Long): Company {
        return Company(id, "Google")
    }
}










### main/kotlin/ru/zavanton/demo/service/CompanyService.kt
package ru.zavanton.demo.service

import ru.zavanton.demo.data.Company

interface CompanyService {

    fun fetchCompany(id: Long): Company
}
