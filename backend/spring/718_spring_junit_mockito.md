# Spring - Testing with JUnit and Mockito (@ExtendWith, @Mock, @Spy, @Captor, @InjectMocks, given().willReturn(), then().should(), Mockito.doThrow(), assertThrows())



### test/kotlin/ru/zavanton/demo/AppTests.kt
package ru.zavanton.demo

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class AppTests {

	@Test
	fun contextLoads() {
	}
}










### test/kotlin/ru/zavanton/demo/DemoTest.kt
package ru.zavanton.demo

import java.lang.RuntimeException
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.ArgumentCaptor
import org.mockito.BDDMockito.anyString
import org.mockito.BDDMockito.given
import org.mockito.Captor
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.Mockito.verify
import org.mockito.Spy
import org.mockito.junit.jupiter.MockitoExtension

@ExtendWith(MockitoExtension::class)
class DemoTest(
    @Mock private val list: ArrayList<String>,
) {
    @Spy
    private val numsSpy: MutableList<Int> = mutableListOf(1, 2, 3)

    @Captor
    lateinit var captor: ArgumentCaptor<String>

    @Test
    fun `test mock`() {
        // mock
        // val listMock = Mockito.mock(ArrayList::class.java)
        // Mockito.doReturn(100).`when`(list).size
        given(list.size).willReturn(100)

        // action
        val actualSize = list.size

        // verify
        assertThat(actualSize).isEqualTo(100)
    }

    @Test
    fun `test spy`() {
        // mock
        // val numbersSpy = Mockito.spy(mutableListOf(1, 2, 3))
        given(numsSpy[0]).willReturn(123)

        // action
        val actualFirstElement = numsSpy[0]
        numsSpy.addAll(listOf(4, 5, 6))

        // verify
        assertThat(numsSpy.size).isEqualTo(6)
        assertThat(actualFirstElement).isEqualTo(123)
    }

    @Test
    fun `test captor`() {
        // mock
        // val captor = ArgumentCaptor.forClass(String::class.java)

        // action
        list.add("Galina")

        // verify
        verify(list).add(captor.capture())
        assertThat(captor.value).isEqualTo("Galina")
    }

    @Test
    fun `test exception`() {
        // mock
        Mockito.doThrow(RuntimeException::class.java).`when`(list).add(anyString())

        // action and verify
        assertThrows<RuntimeException> {
            list.add("Tom")
        }
    }
}










### test/kotlin/ru/zavanton/demo/service/UpperCaseServiceTest.kt
package ru.zavanton.demo.service

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.BDDMockito.atMostOnce
import org.mockito.BDDMockito.given
import org.mockito.BDDMockito.then
import org.mockito.BDDMockito.willThrow
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.junit.jupiter.MockitoExtension
import ru.zavanton.demo.repository.UpperCaseRepository

@ExtendWith(MockitoExtension::class)
internal class UpperCaseServiceTest(
    @Mock
    private val upperCaseRepository: UpperCaseRepository
) {

    @InjectMocks
    lateinit var upperCaseService: UpperCaseServiceImpl

    @Test
    fun `test convertToUpper`() {
        // mock
        val target = "hello"
        // Mockito.doReturn("HELLO").`when`(upperCaseRepository).toUpper(target)
        given(upperCaseRepository.toUpper(target)).willReturn("HELLO")

        // action
        val actual = upperCaseService.convertToUpper(target)

        // verify
        then(upperCaseRepository)
            .should(atMostOnce())
            .toUpper(target)
        assertThat(actual).isEqualTo("HELLO")
    }

    @Test
    fun `test with dynamic value`() {
        // mock
        val target = "hello"
        given(upperCaseRepository.toUpper(target)).will { invocation ->
            if (invocation.getArgument<Any>(0).equals("hello")) {
                "good"
            } else {
                "bad"
            }
        }
        // action
        val actual = upperCaseService.convertToUpper(target)

        // verify
        then(upperCaseRepository)
            .should(atMostOnce())
            .toUpper(target)
        assertThat(actual).isEqualTo("good")
    }

    @Test
    fun `test some exception`() {
        // mock
        val target = "hello"
        val customMessage = "Custom exception"
        val customException = RuntimeException(customMessage)
        given(upperCaseRepository.toUpper(target)).willThrow(customException)

        // action and verify
        assertThrows<RuntimeException>(customMessage) {
            upperCaseService.convertToUpper(target)
        }
    }

    @Test
    fun `test more exception`() {
        // mock
        val target = "hello"
        willThrow(RuntimeException::class.java)
            .given(upperCaseRepository).toUpper(target)

        // action and verify
        assertThrows<RuntimeException> {
            upperCaseService.convertToUpper(target)
        }
    }
}










### main/resources/application.yml
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










### main/kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### main/kotlin/ru/zavanton/demo/repository/UpperCaseRepository.kt
package ru.zavanton.demo.repository

import org.springframework.stereotype.Component

@Component
class UpperCaseRepository {

    fun toUpper(target: String): String {
        return target.uppercase()
    }
}










### main/kotlin/ru/zavanton/demo/service/UpperCaseServiceImpl.kt
package ru.zavanton.demo.service

import org.springframework.stereotype.Component
import ru.zavanton.demo.repository.UpperCaseRepository

@Component
class UpperCaseServiceImpl(
    private val upperCaseRepository: UpperCaseRepository
) : UpperCaseService {

    override fun convertToUpper(target: String): String {
        return upperCaseRepository.toUpper(target)
    }
}










### main/kotlin/ru/zavanton/demo/service/UpperCaseService.kt
package ru.zavanton.demo.service

interface UpperCaseService {

    fun convertToUpper(target: String): String
}
