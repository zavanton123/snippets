# Spring - RestTemplate, MockRestServiceServer and @RestClientTest




### test/kotlin/ru/zavanton/demo/AppTests.kt
package ru.zavanton.demo

import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class AppTests {

}










### test/kotlin/ru/zavanton/demo/client/MyClientTest.kt
package ru.zavanton.demo.client

import com.fasterxml.jackson.databind.ObjectMapper
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.client.RestClientTest
import org.springframework.http.MediaType
import org.springframework.test.web.client.MockRestServiceServer
import org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo
import org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess
import ru.zavanton.demo.data.StudentDTO

@RestClientTest(MyClient::class)
class MyClientTest {

    @Autowired
    private lateinit var client: MyClient

    @Autowired
    private lateinit var server: MockRestServiceServer

    @Autowired
    private lateinit var mapper: ObjectMapper

    @BeforeEach
    fun setup() {
        val student = mapper.writeValueAsString(StudentDTO(0L, "Mike"))
        server.expect(requestTo("http://localhost:8989/person"))
            .andRespond(withSuccess(student, MediaType.APPLICATION_JSON))
    }

    @Test
    fun `test fetchStudent`() {
        val studentDTO = client.fetchStudent()
        assertThat(studentDTO.name).isEqualTo("Mike")
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










### main/kotlin/ru/zavanton/demo/config/RestTemplateConfig.kt
package ru.zavanton.demo.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.client.RestTemplate

@Configuration
class RestTemplateConfig {

    @Bean
    fun restTemplate(): RestTemplate {
        return RestTemplate()
    }
}










### main/kotlin/ru/zavanton/demo/data/StudentDTO.kt
package ru.zavanton.demo.data

class StudentDTO(
    var id: Long = 0L,
    var name: String = ""
)










### main/kotlin/ru/zavanton/demo/controller/DemoController.kt
package ru.zavanton.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.client.MyClient
import ru.zavanton.demo.data.StudentDTO

@RestController
@RequestMapping("/rest")
class DemoController(
    private val client: MyClient
) {
    private val log = LoggerFactory.getLogger(DemoController::class.java)

    @GetMapping("")
    fun home(): StudentDTO {
        return client.fetchStudent()
    }
}









### main/kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import com.fasterxml.jackson.databind.ObjectMapper
import java.net.URI
import org.slf4j.LoggerFactory
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpMethod
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.util.LinkedMultiValueMap
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.client.RestTemplate
import ru.zavanton.demo.data.StudentDTO

@RestController
class MyController(
    private val restTemplate: RestTemplate
) {
    private val log = LoggerFactory.getLogger(MyController::class.java)

    @GetMapping("")
    fun getForEntity(): String {
        val mapper = ObjectMapper()
        val url = "http://localhost:8989/person"
        val response = restTemplate.getForEntity(url, String::class.java)
        if (response.statusCode == HttpStatus.OK) {
            val root = mapper.readTree(response.body)
            val name = root.path("name")
            return name.asText()
        }
        return "home"
    }

    @GetMapping("/json")
    fun getForObject(): StudentDTO {
        val url = "http://localhost:8989/person"
        val studentDTO = restTemplate.getForObject(url, StudentDTO::class.java)
            ?: throw Exception("No student found")
        log.info("zavanton - id: ${studentDTO.id}")
        log.info("zavanton - name: ${studentDTO.name}")
        return studentDTO
    }

    @GetMapping("/headers")
    fun demoHeaders(): String {
        val url = "http://localhost:8989/person"
        val response: HttpHeaders = restTemplate.headForHeaders(url)
        val builder = StringBuilder()
        response.forEach { mapEntry ->
            builder.append(mapEntry.key)
            builder.append(" -> \n")
            mapEntry.value.forEach {
                builder.append(it)
                builder.append("\n")
            }
            builder.append("\n")
        }
        return builder.toString()
    }

    @GetMapping("/post-student")
    fun postForObject(): StudentDTO {
        val entity = HttpEntity<StudentDTO>(StudentDTO(0L, "Tom"))
        val url = "http://localhost:8989/person"
        val studentDTO = restTemplate.postForObject(
            url,
            entity,
            StudentDTO::class.java
        ) ?: throw Exception("No student found")
        log.info("zavanton - student name: ${studentDTO.name}")
        return studentDTO
    }

    @GetMapping("/post-student-location")
    fun postForLocation(): URI {
        val entity = HttpEntity<StudentDTO>(StudentDTO(0L, "Tom"))
        val url = "http://localhost:8989/person"
        val locationUri: URI? = restTemplate.postForLocation(url, entity)
        log.info("zavanton - location uri: $locationUri")
        return locationUri ?: URI.create("http://example.com")
    }

    @GetMapping("/student-exchange")
    fun exchange(): StudentDTO {
        val entity = HttpEntity<StudentDTO>(StudentDTO(0L, "Nick"))
        val url = "http://localhost:8989/person"
        val response: ResponseEntity<StudentDTO> = restTemplate.exchange(
            url,
            HttpMethod.POST,
            entity,
            StudentDTO::class.java
        )
        log.info("zavanton - student name: ${response.body?.name}")
        return response.body ?: throw Exception("Student not found")
    }

    @GetMapping("/form")
    fun submitFormData(): StudentDTO {
        val headers = HttpHeaders()
        headers.contentType = MediaType.APPLICATION_FORM_URLENCODED
        val map = LinkedMultiValueMap<String, String>()
        map.add("id", "0")
        map.add("name", "Sam")
        val entity = HttpEntity(map, headers)
        val url = "http://localhost:8989/person-form"
        val response: ResponseEntity<StudentDTO> =
            restTemplate.postForEntity(url, entity, StudentDTO::class.java)
        return response.body ?: throw Exception("no student found")
    }

    @GetMapping("/options")
    fun optionsForAllow(): String {
        val url = "http://localhost:8989/person"
        val supportedMethods = restTemplate.optionsForAllow(url)
        val builder = StringBuilder()
        supportedMethods.forEach {
            builder.append(it)
            builder.append("\n")
        }
        return builder.toString()
    }
}










### main/kotlin/ru/zavanton/demo/client/MyClient.kt
package ru.zavanton.demo.client

import org.springframework.boot.web.client.RestTemplateBuilder
import org.springframework.stereotype.Component
import org.springframework.web.client.RestTemplate
import ru.zavanton.demo.data.StudentDTO

// Note: implicit constructor injection is used here
@Component
class MyClient(
    restTemplateBuilder: RestTemplateBuilder
) {
    val restTemplate: RestTemplate = restTemplateBuilder.build()

    fun fetchStudent(): StudentDTO {
        return restTemplate.getForObject(
            "http://localhost:8989/person",
            StudentDTO::class.java
        ) ?: throw Exception("No student found")
    }
}
