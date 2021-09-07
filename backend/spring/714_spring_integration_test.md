# Spring - How to do integration tests? @SpringBootTest, @TestPropertySource, @AutoConfigureMockMvc, @ContextConfiguration, @TestConfiguration, @MockBean, @DataJpaTest, @WebMvcTest, TestEntityManager, MockMvc



### main/resources/application.yml
server:
port: 3000

spring:
banner:
image:
location: banner.txt








### main/resources/banner.txt
___________           .__                __
\_   _____/__  ______ |  |  __ __  _____/  |______
|    __)_\  \/ /  _ \|  | |  |  \/    \   __\__  \
|        \\   (  <_> )  |_|  |  /   |  \  |  / __ \_
/_______  / \_/ \____/|____/____/|___|  /__| (____  /
\/                            \/          \/









### main/resources/integration-test.properties
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.password=admin
spring.datasource.username=admin
spring.datasource.url=jdbc:h2:mem:testdb
spring.h2.console.enabled=true
spring.h2.console.path=/h2/
spring.h2.console.settings.trace=false
spring.h2.console.settings.web-allow-others=false
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.defer-datasource-initialization=true

# note: we need this so that test config can override
# the actual beans
spring.main.allow-bean-definition-overriding=true












### test/kotlin/ru/zavanton/demo/AppTests.kt
package ru.zavanton.demo

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.TestPropertySource
import org.springframework.test.web.servlet.MockMvc
import ru.zavanton.demo.service.StudentService

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@TestPropertySource("classpath:integration-test.properties")
@AutoConfigureMockMvc
class AppTests {

    @Autowired
    lateinit var mvc: MockMvc

    // note: here we are loading the actual bean
    @Autowired
    lateinit var studentService: StudentService

    @Test
    fun `test the actual bean label is dev`() {
        assertThat(studentService.label).isEqualTo("dev")
    }
}



















### test/kotlin/ru/zavanton/demo/controller/PersonControllerTest.kt
package ru.zavanton.demo.controller

import org.hamcrest.Matchers.`is`
import org.hamcrest.collection.IsCollectionWithSize.hasSize
import org.junit.jupiter.api.Test
import org.mockito.BDDMockito.given
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import ru.zavanton.demo.data.Person
import ru.zavanton.demo.service.PersonService

@WebMvcTest(controllers = [PersonController::class])
internal class PersonControllerTest {

    @Autowired
    private lateinit var mvc: MockMvc

    @MockBean
    private lateinit var personService: PersonService

    @Test
    fun findAllPersons() {
        // mock
        val persons = listOf(Person(0L, "Mike"))
        given(personService.fetchAll()).willReturn(persons)

        // action and verify
        mvc.perform(
            get("/api/persons")
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$", hasSize<Int>(1)))
            .andExpect(jsonPath("$[0].name", `is`("Mike")))
    }
}





### test/kotlin/ru/zavanton/demo/service/PersonServiceTest.kt
package ru.zavanton.demo.service

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.mockito.BDDMockito.given
import org.mockito.Mockito.`when`
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean
import ru.zavanton.demo.data.Person
import ru.zavanton.demo.repository.PersonRepository

@SpringBootTest
class PersonServiceTest {

    @Autowired
    private lateinit var personService: PersonService

    // note: this overrides the actual bean for this integration test
    @MockBean
    private lateinit var personRepository: PersonRepository

    @Test
    fun `test mocked person repository`() {
        // mock
        val persons = listOf(Person(0L, "Mike"))
        given(personRepository.findAll()).willReturn(persons)

        // action
        val actualPersons = personService.fetchAll()

        // verify
        assertThat(actualPersons).isEqualTo(persons)
    }
}







### test/kotlin/ru/zavanton/demo/repository/PersonRepositoryTest.kt
package ru.zavanton.demo.repository

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager
import ru.zavanton.demo.data.Person

@DataJpaTest
class PersonRepositoryTest {

    // note: test entity manager is used to put some data
    // into the embedded testing H2 database
    @Autowired
    private lateinit var entityManager: TestEntityManager

    @Autowired
    private lateinit var personRepository: PersonRepository

    @Test
    fun `test findByName`() {
        // mock
        val name = "Mike"
        val person = Person(0L, name)
        entityManager.persist(person)
        entityManager.flush()

        // action
        val actualPerson = personRepository.findByName(name)

        // verify
        assertThat(actualPerson.name).isEqualTo(name)
    }
}









### test/kotlin/ru/zavanton/demo/service/StudentServiceTest.kt
package ru.zavanton.demo.service

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.context.TestPropertySource

@SpringBootTest
// note: @Import is ok as well
//@Import(StudentServiceConfig::class)
@ContextConfiguration(classes = [StudentServiceConfig::class])
@TestPropertySource("classpath:integration-test.properties")
class StudentServiceTest {

    // note: here we are loading the test bean from the StudentServiceConfig
    @Autowired
    private lateinit var studentService: StudentService

    @Test
    fun `test the test bean label is test`() {
        assertFalse(false)
        assertThat(studentService.label).isEqualTo("test")
    }
}






### test/kotlin/ru/zavanton/demo/service/StudentServiceConfig.kt
package ru.zavanton.demo.service

import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.annotation.Bean
import ru.zavanton.demo.service.StudentService

// this config overrides the actual bean StudentService
// for our integration test
@TestConfiguration
class StudentServiceConfig {

    // note: we need spring.main.allow-bean-definition-overriding=true
    // to allow test configuration to override the actual beans.
    // Otherwise if spring.main.allow-bean-definition-overriding=false
    // then the name of this test bean
    // must be different from the name of the actual bean
    // (i.e. @Bean("testStudentService")
    @Bean
    fun provideStudentService(): StudentService {
        return StudentService("test")
    }
}










### test/kotlin/ru/zavanton/demo/service/PersonServiceTestTwo.kt
package ru.zavanton.demo.service

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.mockito.BDDMockito.given
import org.mockito.Mockito.mock
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.annotation.Bean
import org.springframework.test.context.TestPropertySource
import ru.zavanton.demo.data.Person
import ru.zavanton.demo.repository.PersonRepository

@SpringBootTest
@TestPropertySource("classpath:integration-test.properties")
class PersonServiceTestTwo {

    // note: this is a static inner class,
    // so this configuration is applied to this PersonServiceTestTwo
    // test automatically
    @TestConfiguration
    class PersonServiceTestConfig {

        @Bean
        fun personService(): PersonService {
            val personRepository = mock(PersonRepository::class.java)
            val persons = listOf(Person(0L, "Mike"))
            given(personRepository.findAll()).willReturn(persons)

            return PersonServiceImpl(personRepository)
        }
    }

    @Autowired
    private lateinit var personService: PersonService

    @Test
    fun `test mocked person repository`() {
        val actualPersons = personService.fetchAll()
        assertThat(actualPersons).hasSize(1)
    }
}





### main/kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}






### main/kotlin/ru/zavanton/demo/controller/PersonController.kt
package ru.zavanton.demo.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.data.Person
import ru.zavanton.demo.service.PersonService

@RestController
@RequestMapping("/api")
class PersonController(
    private val personService: PersonService
) {

    @GetMapping("/persons")
    fun findAllPersons(): List<Person> {
        return personService.fetchAll()
    }
}





### main/kotlin/ru/zavanton/demo/service/StudentService.kt
package ru.zavanton.demo.service

import org.springframework.stereotype.Service

@Service
class StudentService(
    val label: String = "dev"
)






### main/kotlin/ru/zavanton/demo/service/PersonService.kt
package ru.zavanton.demo.service

import ru.zavanton.demo.data.Person

interface PersonService {

    fun fetchAll(): List<Person>
}





### main/kotlin/ru/zavanton/demo/service/PersonServiceImpl.kt
package ru.zavanton.demo.service

import org.springframework.stereotype.Service
import ru.zavanton.demo.data.Person
import ru.zavanton.demo.repository.PersonRepository

@Service
class PersonServiceImpl(
private val personRepository: PersonRepository
) : PersonService {

    override fun fetchAll(): List<Person> {
        return personRepository.findAll()
    }
}







### main/kotlin/ru/zavanton/demo/repository/PersonRepository.kt
package ru.zavanton.demo.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.data.Person

@Repository
interface PersonRepository : JpaRepository<Person, Long> {

    fun findByName(name: String): Person
}





### main/kotlin/ru/zavanton/demo/data/Person.kt
package ru.zavanton.demo.data

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
class Person(
@Id
@GeneratedValue(strategy = GenerationType.IDENTITY)
var id: Long = 0L,
var name: String = ""
)

