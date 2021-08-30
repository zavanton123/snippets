# Spring - Data, How to initialize data? schema.sql, data.sql, @Sql, @SqlGroup, @SqlConfig



### test/kotlin/zavanton/ru/demo/AppTests.kt
package zavanton.ru.demo

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class AppTests {

	@Test
	fun contextLoads() {
	}

}










### test/kotlin/zavanton/ru/demo/repository/CountryRepositoryTest.kt
package zavanton.ru.demo.repository

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.test.context.jdbc.Sql
import org.springframework.test.context.jdbc.SqlConfig

@DataJpaTest
@Sql("/import_countries.sql")
class CountryRepositoryTest {

    @Autowired
    lateinit var countryRepository: CountryRepository

    @Test
    fun test() {
        // note: 3 is from data.sql
        // another 3 is from import_countries.sql
        val actualSize = 3 + 3

        assertThat(countryRepository.findAll().size).isEqualTo(actualSize)
    }

    @Test
    @Sql(
        scripts = ["/import_more_countries.sql"],
        config = SqlConfig(
            transactionMode = SqlConfig.TransactionMode.ISOLATED,
            encoding = "utf-8"
        )
    )
    fun more_test() {
        // note: 3 is from data.sql
        // another 2 is from import_more_countries.sql
        val actualSize = 3 + 2

        assertThat(countryRepository.findAll().size).isEqualTo(actualSize)
    }
}










### test/kotlin/zavanton/ru/demo/repository/CountryRepositoryTest2.kt
package zavanton.ru.demo.repository

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.test.context.jdbc.Sql
import org.springframework.test.context.jdbc.SqlGroup

@DataJpaTest
@SqlGroup(
    Sql("/import_countries.sql"),
    Sql("/import_more_countries.sql")
)
class CountryRepositoryTest2 {

    @Autowired
    lateinit var countryRepository: CountryRepository

    @Test
    fun test() {
        // note: 3 is from data.sql
        // another 3 is from import_countries.sql
        // another 2 is from import_more_countries.sql
        val actualSize = 3 + 3 + 2

        assertThat(countryRepository.findAll().size).isEqualTo(actualSize)
    }
}










### main/resources/data.sql
insert into country (name)
values ('Russia');
insert into country (name)
values ('Brazil');
insert into country (name)
values ('China');










### main/resources/import_more_countries.sql
insert into country (name) values ('France');
insert into country (name) values ('Germany');










### main/resources/schema.sql
CREATE TABLE country
(
    id   INTEGER      NOT NULL AUTO_INCREMENT,
    name VARCHAR(128) NOT NULL,
    PRIMARY KEY (id)
);










### main/resources/import_countries.sql
insert into country (name) values ('USA');
insert into country (name) values ('UK');
insert into country (name) values ('Canada');










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
    # turn off the ddl autogeneration, because we are using schema.sql
    generate-ddl: false
    # turn off the ddl autogeneration, because we are using schema.sql
    hibernate:
      ddl-auto: none










### main/kotlin/zavanton/ru/demo/App.kt
package zavanton.ru.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
	runApplication<App>(*args)
}










### main/kotlin/zavanton/ru/demo/repository/CountryRepository.kt
package zavanton.ru.demo.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import zavanton.ru.demo.entity.Country

@Repository
interface CountryRepository : JpaRepository<Country, Int>










### main/kotlin/zavanton/ru/demo/entity/Country.kt
package zavanton.ru.demo.entity

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
data class Country(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Int = 0,

    val name: String = ""
)
