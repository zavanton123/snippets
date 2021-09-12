# Spring - JUnit 5 features









### test/resources/data.csv
1,1
2,4
3,9










### test/kotlin/ru/zavanton/demo/AppTest.kt
package ru.zavanton.demo

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class AppTest {

//	@Test
//	fun contextLoads() {
//	}

}










### test/kotlin/ru/zavanton/demo/SpringJUnitConfigTest.kt
package ru.zavanton.demo

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.context.ApplicationContext
import org.springframework.test.context.junit.jupiter.SpringJUnitConfig
import ru.zavanton.demo.config.TestConfig

// Note: this is the same as
//@ExtendWith(SpringExtension::class)
//@ContextConfiguration(classes = [TestConfig::class])
@SpringJUnitConfig(TestConfig::class)
class SpringJUnitConfigTest(
    private val applicationContext: ApplicationContext,
    @Qualifier("testusername")
    private val testUsername: String,
) {
    @Test
    fun `test username`() {
        assertThat(testUsername).isEqualTo("testy")
    }
}










### test/kotlin/ru/zavanton/demo/DemoTest.kt
package ru.zavanton.demo

import java.time.Duration
import java.util.stream.Stream
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.AfterAll
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Assertions.fail
import org.junit.jupiter.api.Assumptions.assumeTrue
import org.junit.jupiter.api.Assumptions.assumingThat
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Disabled
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.Tag
import org.junit.jupiter.api.Tags
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestFactory
import org.junit.jupiter.api.TestInstance
import org.junit.jupiter.api.assertAll
import org.junit.jupiter.api.assertThrows
import org.junit.jupiter.api.assertTimeout
import org.junit.jupiter.api.extension.ExtensionContext
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.Arguments
import org.junit.jupiter.params.provider.ArgumentsProvider
import org.junit.jupiter.params.provider.ArgumentsSource
import org.junit.jupiter.params.provider.CsvFileSource
import org.junit.jupiter.params.provider.CsvSource
import org.junit.jupiter.params.provider.EmptySource
import org.junit.jupiter.params.provider.EnumSource
import org.junit.jupiter.params.provider.MethodSource
import org.junit.jupiter.params.provider.NullAndEmptySource
import org.junit.jupiter.params.provider.NullSource
import org.junit.jupiter.params.provider.ValueSource
import org.slf4j.LoggerFactory
import ru.zavanton.demo.data.Week


@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class DemoTest {
    private val log = LoggerFactory.getLogger(DemoTest::class.java)

    @BeforeAll
    fun beforeAll() = log.info("zavanton - @BeforeAll")

    @AfterAll
    fun afterAll() = log.info("zavanton - @AfterAll")

    @BeforeEach
    fun beforeEach() = log.info("zavanton - @BeforeEach")

    @AfterEach
    fun afterEach() = log.info("zavanton - @AfterEach")

    // use @DisplayName to make the test name more readable
    @Test
    @DisplayName("first test")
    fun test_first() {
        assertFalse(false)
    }

    // use backticks to make the test name more readable
    @Test
    fun `second test`() {
        assertFalse(false)
    }

    // this test will not be run
    @Disabled
    @Test
    fun `third test`() {
        assertFalse(false)
    }

    @Test
    fun `test group assertions`() {
        assertAll(
            "numbers",
            { assertThat(2).isEqualTo(2) },
            { assertThat(3).isEqualTo(3) },
            { assertThat(4).isEqualTo(4) },
        )
    }

    @Test
    fun `test assumption`() {
        // note: if the assumption is not true, the test is not run
        val someCondition = 5 < 1
        assumeTrue(someCondition)
        assertEquals(7, 5 + 2)
    }

    @Test
    fun `test assumption with lambda`() {
        // note: if the assumption is not true, the test is not run
        assumingThat({
            5 < 1
        }) {
            assertThat(2).isEqualTo(2)
        }
    }

    @Test
    fun `test exceptions`() {
        val exception = assertThrows<RuntimeException> {
            throw RuntimeException("Custom Message")
        }
        assertThat(exception.message).isEqualTo("Custom Message")
    }

    @Test
    fun `test with fail`() {
        try {
            // call some method that should throw an exception
            throw RuntimeException("Custom Message")
            fail("Exception not thrown")
        } catch (e: java.lang.RuntimeException) {
            assertTrue(true)
        }
    }

    @Test
    fun `test with timeout`() {
        assertTimeout(Duration.ofMillis(100)) {
            Thread.sleep(50)
        }
    }

    // dynamic tests are created at runtime
    @TestFactory
    fun `test dynamic tests`(): List<DynamicTest> {
        return listOf(1, 2, 3, 4, 5).map { number ->
            DynamicTest.dynamicTest("Number test") {
                assertThat(number).isPositive()
            }
        }
    }

    @ParameterizedTest
    @MethodSource("nums")
    fun `test with params`(input: Int, expected: Int) {
        assertThat(input * input).isEqualTo(expected)
    }

    companion object {
        @JvmStatic
        fun nums() = listOf(
            Arguments.of(1, 1),
            Arguments.of(2, 4),
            Arguments.of(3, 9),
        )
    }

    @ParameterizedTest
    @CsvSource("1, 1", "2, 4", "3, 9")
    fun `test with params via csv source`(input: Int, expected: Int) {
        assertThat(input * input).isEqualTo(expected)
    }

    @ParameterizedTest
    @CsvSource(value = ["1:1", "2:4", "3:9"], delimiter = ':')
    fun `test with params via csv source with delimiter`(input: Int, expected: Int) {
        assertThat(input * input).isEqualTo(expected)
    }

    @ParameterizedTest
    @CsvFileSource(resources = ["/data.csv"])
    fun `test with CSV file source`(input: Int, expected: Int){
        assertThat(input * input).isEqualTo(expected)
    }

    @ParameterizedTest
    @ValueSource(ints = [1, 3, 5, 7, 9])
    fun `test with params via value source`(num: Int) {
        assertThat(num).isOdd()
    }

    @ParameterizedTest
    @NullSource
    fun `test is null`(num: Int?) {
        assertThat(num).isNull()
    }

    @ParameterizedTest
    @EmptySource
    fun `test is empty`(name: String) {
        assertThat(name).isEmpty()
    }

    @ParameterizedTest
    @NullAndEmptySource
    fun `test is null or empty`(name: String?) {
        assertThat(name).isNullOrEmpty()
    }

    @ParameterizedTest
    @EnumSource(value = Week::class, names = ["MON", "TUE", "WED"])
    fun `test enum source`(week: Week) {
        val index = week.ordinal
        assertThat(index).isLessThan(3)
    }

    @ParameterizedTest
    @ArgumentsSource(CustomArgumentProvider::class)
    fun `test with custom argument provider`(input: Int, expected: Int) {
        assertThat(input * input).isEqualTo(expected)
    }

    class CustomArgumentProvider : ArgumentsProvider {
        override fun provideArguments(context: ExtensionContext): Stream<out Arguments> {
            return Stream.of(
                Arguments.of(1, 1),
                Arguments.of(2, 4),
                Arguments.of(3, 9),
            )
        }
    }

    @Test
    @Tags(
        Tag("slow"),
        Tag("custom"),
    )
    fun `test with tags`() {
        assertFalse(false)
    }
}










### test/kotlin/ru/zavanton/demo/SpringJUnitWebConfigTest.kt
package ru.zavanton.demo

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.test.context.junit.jupiter.web.SpringJUnitWebConfig
import org.springframework.web.context.WebApplicationContext
import ru.zavanton.demo.config.TestConfig

// Note: this is the same as
//@ExtendWith(SpringExtension::class)
//@ContextConfiguration(classes = [TestConfig::class])
//@WebAppConfiguration
@SpringJUnitWebConfig(TestConfig::class)
class SpringJUnitWebConfigTest(
    private val webApplicationContext: WebApplicationContext,
    @Qualifier("testusername")
    private val testUsername: String,
) {

    @Test
    fun `test demo`() {
        assertThat(testUsername).isEqualTo("testy")
    }
}










### test/kotlin/ru/zavanton/demo/config/TestConfig.kt
package ru.zavanton.demo.config

import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class TestConfig {

    @Bean
    @Qualifier("testusername")
    fun testUsername(): String {
        return "testy"
    }
}










### main/resources/application.properties
server.port=9999











### main/kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
	runApplication<App>(*args)
}










### main/kotlin/ru/zavanton/demo/data/Week.kt
package ru.zavanton.demo.data

enum class Week {
    MON,
    TUE,
    WED,
    THU,
    FRI,
    SAT,
    SUN
}
