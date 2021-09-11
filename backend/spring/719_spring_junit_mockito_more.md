# Spring - Testing with JUnit and Mockito (test final classes, Answer, argument matcher, argument captor, InOrder, etc.)



### test/resources/mockito-extensions/org.mockito.plugins.MockMaker
mock-maker-inline










### test/kotlin/ru/zavanton/demo/AppTests.kt
package ru.zavanton.demo

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class AppTests {

//	@Test
//	fun contextLoads() {
//	}
}










### test/kotlin/ru/zavanton/demo/repository/CustomFinalStudentRepoTest.kt
package ru.zavanton.demo.repository

import com.nhaarman.mockitokotlin2.mock
import com.nhaarman.mockitokotlin2.verify
import com.nhaarman.mockitokotlin2.whenever
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test


// note: even though the CustomFinalStudentRepo
// is a final class
// it can be mocked, because we have enabled
// the MockMaker plugin by adding mock-maker-inline
// to the file: test/resources/mockito-extensions/org.mockito.plugins.MockMaker
internal class CustomFinalStudentRepoTest {

    @Test
    fun showInfo() {
        // mock
        val mock = mock<CustomFinalStudentRepo>()
        whenever(mock.showInfo()).thenAnswer { "Ok" }

        // action
        val actual = mock.showInfo()

        // verify
        verify(mock).showInfo()
        assertThat(actual).isEqualTo("Ok")
    }
}










### test/kotlin/ru/zavanton/demo/service/EmailServiceTest.kt
package ru.zavanton.demo.service

import com.nhaarman.mockitokotlin2.any
import com.nhaarman.mockitokotlin2.argumentCaptor
import com.nhaarman.mockitokotlin2.verify
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.junit.jupiter.MockitoExtension
import ru.zavanton.demo.data.CustomEmail
import ru.zavanton.demo.data.EmailFormat
import ru.zavanton.demo.repository.DeliveryPlatform

@ExtendWith(MockitoExtension::class)
internal class EmailServiceTest(
    @Mock
    private val deliveryPlatform: DeliveryPlatform,
) {

    @InjectMocks
    private lateinit var emailService: EmailService

    @Test
    fun `test with argument captor`() {
        // mock
        val to = "to"
        val subject = "subject"
        val body = "body"
        val isHtml = false
        val expectedEmail = CustomEmail(to, subject, body, EmailFormat.PLAIN_TEXT)
        Mockito.doNothing().`when`(deliveryPlatform).deliver(any())

        // action
        emailService.send(to, subject, body, isHtml)

        // verify
        val captor = argumentCaptor<CustomEmail>()
        verify(deliveryPlatform).deliver(captor.capture())
        assertThat(captor.firstValue).isEqualTo(expectedEmail)
    }
}










### test/kotlin/ru/zavanton/demo/service/CustomListTest.kt
package ru.zavanton.demo.service

import com.nhaarman.mockitokotlin2.any
import com.nhaarman.mockitokotlin2.eq
import com.nhaarman.mockitokotlin2.mock
import com.nhaarman.mockitokotlin2.verify
import com.nhaarman.mockitokotlin2.whenever
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.mockito.ArgumentMatchers.anyInt
import org.mockito.ArgumentMatchers.anyString
import org.mockito.Mockito


class CustomListTest {

    @Test
    fun `test Answer`() {
        // mock
        // note: setup the default answer
        val customList = mock<CustomList>() {
            "odd"
        }
        // note: setup the custom answer
        Mockito.doAnswer {
            val firstArg = it.getArgument<Int>(0)
            if (firstArg % 2 == 0) "even" else "odd"
        }.`when`(customList).get(anyInt())

        // action
        val actual = customList.get(3)

        // verify
        assertThat(actual).isEqualTo("odd")
    }

    @Test
    fun `test argument matchers`() {
        // mock
        val customList = mock<CustomList>()
        whenever(
            customList.get(
                any(),
                eq("more")
            )
        ).thenReturn("hello")

        // action
        val actual = customList.get(0, "more")

        // verify
        assertThat(actual).isEqualTo("hello")
        verify(customList).get(anyInt(), anyString())
    }
}










### test/kotlin/ru/zavanton/demo/service/MessageServiceTest.kt
package ru.zavanton.demo.service

import com.nhaarman.mockitokotlin2.any
import com.nhaarman.mockitokotlin2.argThat
import com.nhaarman.mockitokotlin2.argumentCaptor
import com.nhaarman.mockitokotlin2.atMost
import com.nhaarman.mockitokotlin2.eq
import com.nhaarman.mockitokotlin2.given
import com.nhaarman.mockitokotlin2.inOrder
import com.nhaarman.mockitokotlin2.spy
import com.nhaarman.mockitokotlin2.verify
import com.nhaarman.mockitokotlin2.whenever
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.ArgumentMatcher
import org.mockito.ArgumentMatchers.anyLong
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.junit.jupiter.MockitoExtension
import ru.zavanton.demo.data.Message
import ru.zavanton.demo.dto.MessageDTO
import ru.zavanton.demo.repository.MessageHelper
import ru.zavanton.demo.repository.MessageRepository


@ExtendWith(MockitoExtension::class)
internal class MessageServiceTest(
    @Mock
    private val messageRepository: MessageRepository,
    @Mock
    private val messageHelper: MessageHelper,
) {

    @InjectMocks
    private lateinit var messageService: MessageService

//    private val messageRepository = mock<MessageRepository>()
//    private val messageService = MessageService(messageRepository)

    class CustomMessageMatcher(
        private val message: Message
    ) : ArgumentMatcher<Message> {

        override fun matches(argument: Message): Boolean {
            return message.id == argument.id &&
                    message.content == argument.content
        }
    }

    @Test
    fun `test with a regular argument matcher any()`() {
        // mock
        val messageDto = MessageDTO(0L, "Text")
        whenever(messageRepository.processMessage(any()))
            .thenReturn(false)

        // action
        val actual = messageService.sendMessage(messageDto)

        // verify
        assertThat(actual).isEqualTo(false)
        verify(messageRepository, atMost(1))
            .processMessage(any())
    }

    @Test
    fun `test with custom argument matcher`() {
        // mock
        val messageDto = MessageDTO(0L, "Text")
        val message = Message(0L, "Text")
        whenever(messageRepository.processMessage(any()))
            .thenReturn(false)

        // action
        val actual = messageService.sendMessage(messageDto)

        // verify
        assertThat(actual).isEqualTo(false)
        // note: custom matcher is used
        verify(messageRepository).processMessage(argThat(CustomMessageMatcher(message)))
    }

    @Test
    fun `test with custom argument matcher as lambda`() {
        // mock
        val messageDto = MessageDTO(0L, "Text")
        val message = Message(0L, "Text")
        whenever(messageRepository.processMessage(any())).thenReturn(false)

        // action
        val actual = messageService.sendMessage(messageDto)

        // verify
        assertThat(actual).isEqualTo(false)
        // note: custom matcher as lambda
        verify(messageRepository).processMessage(argThat {
            message.id == id && message.content == content
        })
        verify(messageRepository).processMessage(argThat(CustomMessageMatcher(message)))
    }

    @Test
    fun `test with argument captor`() {
        // mock
        val messageDto = MessageDTO(0L, "Text")
        val message = Message(0L, "Text")
        whenever(messageRepository.processMessage(message)).thenReturn(false)

        // action
        val actual = messageService.sendMessage(messageDto)

        // verify
        assertThat(actual).isEqualTo(false)
        val messageCaptor = argumentCaptor<Message>()
        verify(messageRepository).processMessage(messageCaptor.capture())
        assertThat(messageCaptor.firstValue.id).isEqualTo(0L)
        assertThat(messageCaptor.firstValue.content).isEqualTo("Text")
    }

    @Test
    fun `test with argument captor - alternative captor syntax`() {
        // mock
        val messageDto = MessageDTO(0L, "Text")
        val message = Message(0L, "Text")
        whenever(messageRepository.processMessage(message)).thenReturn(false)

        // action
        val actual = messageService.sendMessage(messageDto)

        // verify
        argumentCaptor<Message> {
            verify(messageRepository).processMessage(capture())
            assertThat(firstValue.id).isEqualTo(0L)
            assertThat(firstValue.content).isEqualTo("Text")
            assertThat(actual).isEqualTo(false)
        }
    }

    @Test
    fun `test with argument captor - another example`() {
        // mock
        val messageDto = MessageDTO(0L, "Text")
        val captor = argumentCaptor<Message>()
        whenever(messageRepository.processMessage(captor.capture()))
            .thenReturn(false)

        // action
        val actual = messageService.sendMessage(messageDto)

        // verify
        assertThat(actual).isEqualTo(false)
        verify(messageRepository).processMessage(any())
        assertThat(captor.firstValue.id).isEqualTo(0L)
        assertThat(captor.firstValue.content).isEqualTo("Text")
    }

    @Test
    fun `test with Answer`() {
        // mock
        val messageDto = MessageDTO(0L, "Text")
        val message = Message(0L, "Text")
        Mockito.doAnswer {
            val messageArg = it.getArgument<Message>(0)
            assertThat(messageArg.content.length).isGreaterThan(0)
            messageArg.content.length < 10
        }
            .`when`(messageRepository).processMessage(message)

        // action
        val actual = messageService.sendMessage(messageDto)

        // verify
        verify(messageRepository).processMessage(message)
        assertThat(actual).isEqualTo(true)
    }

    @Test
    fun `test method with void return value - using captor`() {
        // mock
        val messageDto = MessageDTO(0L, "Text")
        val captor = argumentCaptor<Message>()
        Mockito.doNothing()
            .`when`(messageRepository)
            .consumeMessage(captor.capture())

        // action
        messageService.consumeMessage(messageDto)

        // verify
        verify(messageRepository).consumeMessage(any())
        assertThat(captor.firstValue.id).isEqualTo(0L)
        assertThat(captor.firstValue.content).isEqualTo("Text")
    }

    @Test
    fun `test method with void return value - using Answer and captor`() {
        // mock
        val messageDto = MessageDTO(0L, "Text")
        val captor = argumentCaptor<Message>()
        // note: this mocks the Unit return value
        given(messageRepository.consumeMessage(captor.capture())).willAnswer { }

        // action
        messageService.consumeMessage(messageDto)

        // verify
        verify(messageRepository).consumeMessage(any())
        assertEquals(0L, captor.firstValue.id)
        assertEquals("Text", captor.firstValue.content)
    }

    @Test
    fun `test method with exception`() {
        // mock
        val messageDto = MessageDTO(0L, "Text")
        val message = Message(0L, "Text")
        Mockito.doThrow(RuntimeException::class.java)
            .`when`(messageRepository)
            .failToProcessMessage(message)

        // action and verify
        assertThrows<RuntimeException> {
            messageService.failToProcessMessage(messageDto)
        }
    }

    @Test
    fun `test with doCallRealMethod`() {
        // mock
        Mockito.doCallRealMethod()
            .`when`(messageRepository).showNumber()

        // action
        val actual = messageService.showNumber()

        // verify
        assertThat(actual).isEqualTo(123)
    }

    @Test
    fun `test with spy`() {
        // mock
        val repo = MessageRepository()
        val repoSpy = spy(repo)
        val service = MessageService(repoSpy, messageHelper)

        // action
        val actual = service.showNumber()

        // verify
        assertThat(actual).isEqualTo(123)
    }

    @Test
    fun `test order`() {
        // mock
        val messageDto = MessageDTO(0L, "Text")
        whenever(messageHelper.checkMessage(any())).thenReturn(true)
        whenever(messageRepository.processMessage(any())).thenReturn(true)

        // action
        messageService.validateAndSendMessage(messageDto)

        // verify
//        val inOrder = Mockito.inOrder(messageHelper, messageRepository)
//        inOrder.verify(messageHelper).checkMessage(any())
//        inOrder.verify(messageRepository).processMessage(any())
        inOrder(messageHelper, messageRepository) {
            verify(messageHelper).checkMessage(any())
            verify(messageRepository).processMessage(any())
        }
    }

    @Test
    fun `test callback with captor`() {
        // mock
        val messageId = 0L
        val message = Message(messageId, "hello world")
        val captor = argumentCaptor<(Message) -> String>()
        Mockito.doNothing()
            .`when`(messageRepository).processWithCallback(eq(messageId), captor.capture())

        // action
        messageService.processWithCallback(messageId)
        // note: imitate the repository invokes the callback
        captor.firstValue.invoke(message)

        // verify
        verify(messageRepository).processWithCallback(anyLong(), any())
        assertThat(message.content).isEqualTo("HELLO WORLD")
    }

    @Test
    fun `test callback with Answer`() {
        // mock
        val message = Message(0L, "hello world")
        Mockito.doAnswer {
            val callback = it.getArgument<(Message) -> String>(1)
            callback.invoke(message)
            assertThat(message.content).isEqualTo("HELLO WORLD")
        }.`when`(messageRepository).processWithCallback(anyLong(), any())

        // action
        messageService.processWithCallback(0L)

        // verify
        verify(messageRepository).processWithCallback(anyLong(), any())
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










### main/kotlin/ru/zavanton/demo/repository/DeliveryPlatform.kt
package ru.zavanton.demo.repository

import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component
import ru.zavanton.demo.data.CustomEmail

@Component
class DeliveryPlatform {
    private val log = LoggerFactory.getLogger(DeliveryPlatform::class.java)

    fun deliver(email: CustomEmail) {
        log.info("zavanton - the email $email is delivered")
    }
}










### main/kotlin/ru/zavanton/demo/repository/MessageHelper.kt
package ru.zavanton.demo.repository

import org.springframework.stereotype.Component
import ru.zavanton.demo.data.Message

@Component
class MessageHelper {

    fun checkMessage(message: Message) : Boolean {
        return message.content.length > 2
    }
}










### main/kotlin/ru/zavanton/demo/repository/MessageRepository.kt
package ru.zavanton.demo.repository

import org.slf4j.LoggerFactory
import org.springframework.stereotype.Repository
import ru.zavanton.demo.data.Message

@Repository
class MessageRepository {

    private val log = LoggerFactory.getLogger(MessageRepository::class.java)

    fun processMessage(message: Message): Boolean {
        return true
    }

    fun consumeMessage(message: Message) {
        log.info("zavanton - the message $message is consumed")
    }

    fun failToProcessMessage(message: Message): Boolean {
        throw RuntimeException("Failed to process the message $message")
    }

    fun showNumber(): Int {
        return 123
    }

    fun processWithCallback(messageId: Long, callback: (Message) -> String) {
        val message = Message(messageId, "Hello world")
        callback(message)
    }
}










### main/kotlin/ru/zavanton/demo/repository/CustomFinalStudentRepo.kt
package ru.zavanton.demo.repository

class CustomFinalStudentRepo {

    fun showInfo(): String {
        return "info"
    }
}










### main/kotlin/ru/zavanton/demo/data/CustomEmail.kt
package ru.zavanton.demo.data

class CustomEmail(
    var to: String,
    var subject: String,
    var body: String,
    var format: EmailFormat,
) {
    override fun toString(): String {
        return "CustomEmail(to='$to', subject='$subject', body='$body', format=$format)"
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as CustomEmail

        if (to != other.to) return false
        if (subject != other.subject) return false
        if (body != other.body) return false
        if (format != other.format) return false

        return true
    }

    override fun hashCode(): Int {
        var result = to.hashCode()
        result = 31 * result + subject.hashCode()
        result = 31 * result + body.hashCode()
        result = 31 * result + format.hashCode()
        return result
    }
}










### main/kotlin/ru/zavanton/demo/data/EmailFormat.kt
package ru.zavanton.demo.data

enum class EmailFormat {
    HTML,
    PLAIN_TEXT
}










### main/kotlin/ru/zavanton/demo/data/Message.kt
package ru.zavanton.demo.data

class Message(
    var id: Long = 0L,
    var content: String = ""
) {

    override fun toString(): String {
        return "Message(id=$id, content='$content')"
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as Message

        if (id != other.id) return false
        if (content != other.content) return false

        return true
    }

    override fun hashCode(): Int {
        var result = id.hashCode()
        result = 31 * result + content.hashCode()
        return result
    }
}










### main/kotlin/ru/zavanton/demo/dto/MessageDTO.kt
package ru.zavanton.demo.dto

class MessageDTO(
    var id: Long = 0L,
    var text: String = ""
)










### main/kotlin/ru/zavanton/demo/service/EmailService.kt
package ru.zavanton.demo.service

import org.springframework.stereotype.Service
import ru.zavanton.demo.data.CustomEmail
import ru.zavanton.demo.data.EmailFormat
import ru.zavanton.demo.repository.DeliveryPlatform

@Service
class EmailService(
    private val deliveryPlatform: DeliveryPlatform
) {

    fun send(to: String, subject: String, body: String, isHtml: Boolean) {
        val format = if (isHtml) EmailFormat.HTML else EmailFormat.PLAIN_TEXT
        val customEmail = CustomEmail(to, subject, body, format)
        deliveryPlatform.deliver(customEmail)
    }
}










### main/kotlin/ru/zavanton/demo/service/MessageService.kt
package ru.zavanton.demo.service

import org.springframework.stereotype.Component
import ru.zavanton.demo.data.Message
import ru.zavanton.demo.dto.MessageDTO
import ru.zavanton.demo.repository.MessageHelper
import ru.zavanton.demo.repository.MessageRepository

@Component
class MessageService(
    private val messageRepository: MessageRepository,
    private val messageHelper: MessageHelper,
) {

    fun sendMessage(dto: MessageDTO): Boolean {
        val entity = Message(id = dto.id, content = dto.text)
        return messageRepository.processMessage(entity)
    }

    fun consumeMessage(dto: MessageDTO) {
        val entity = Message(id = dto.id, content = dto.text)
        messageRepository.consumeMessage(entity)
    }

    fun failToProcessMessage(dto: MessageDTO): Boolean {
        val entity = Message(id = dto.id, content = dto.text)
        return messageRepository.failToProcessMessage(entity)
    }

    fun showNumber(): Int {
        return messageRepository.showNumber()
    }

    fun validateAndSendMessage(dto: MessageDTO): Boolean {
        val entity = Message(id = dto.id, content = dto.text)
        return messageHelper.checkMessage(entity) &&
                messageRepository.processMessage(entity)
    }

    fun processWithCallback(messageId: Long) {
        return messageRepository.processWithCallback(0L) { message: Message ->
            message.content = message.content.uppercase()
            message.content
        }
    }
}










### main/kotlin/ru/zavanton/demo/service/CustomList.kt
package ru.zavanton.demo.service

import org.springframework.stereotype.Component

@Component
class CustomList {

    fun get(index: Int): String {
        return "hello"
    }

    fun get(index: Int, defaultResult: String) : String {
        return "great"
    }

    val size: Int
        get() = 1
}





# build.gradle.kts
```
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.4"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.21"
	kotlin("plugin.spring") version "1.5.21"
}

group = "ru.zavanton"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_1_8

repositories {
	mavenCentral()
}

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    // validation
	implementation("org.springframework.boot:spring-boot-starter-validation")
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("com.h2database:h2")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
	// mockito for kotlin
	testImplementation("com.nhaarman.mockitokotlin2:mockito-kotlin:2.2.0")
}

tasks.withType<KotlinCompile> {
	kotlinOptions {
		freeCompilerArgs = listOf("-Xjsr305=strict")
		jvmTarget = "1.8"
	}
}

tasks.withType<Test> {
	useJUnitPlatform()
}
```
