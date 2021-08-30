# Spring - Data, JPA automatic and manual custom queries, @Query, @Modifying, JPQL and SQL, JPA Criteria API




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
import zavanton.ru.demo.entity.Country

@DataJpaTest
class CountryRepositoryTest {

    @Autowired
    lateinit var countryRepository: CountryRepository

    @Test
    fun `test automatic custom query`() {
        // mock
        val country = Country(name = "Mexico")
        val savedCountry = countryRepository.save(country)

        // action
        val actualCountry = countryRepository.findByName(country.name)

        // verify
        assertThat(actualCountry).isEqualTo(country)
    }

    @Test
    fun `test manual custom query`() {
        // mock
        val country = Country(name = "Mexico")
        val savedCountry = countryRepository.save(country)

        // action
        val actualCountry = countryRepository.extractByName(country.name)

        // verify
        assertThat(actualCountry).isEqualTo(country)
    }

    @Test
    fun `test fetchAll with native SQL query`() {
        // mock

        // action
        val actualCountries = countryRepository.fetchAll()

        // verify
        assertThat(actualCountries.size).isEqualTo(3)
    }
}










### main/resources/data.sql
insert into country (name) values ('Russia');
insert into country (name) values ('Brazil');
insert into country (name) values ('China');










### main/resources/schema.sql
CREATE TABLE country
(
    id   INTEGER      NOT NULL AUTO_INCREMENT,
    name VARCHAR(128) NOT NULL,
    PRIMARY KEY (id)
);










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

import org.springframework.data.domain.Pageable
import org.springframework.data.domain.Sort
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import org.springframework.stereotype.Repository
import zavanton.ru.demo.entity.Country

@Repository
interface CountryRepository : JpaRepository<Country, Int>, CustomCountryRepository {

    // automatic custom query
    fun findByName(name: String): Country


    // MANUAL QUERIES
    // manual custom query (JPQL example)
    @Query("select c from Country c where lower(c.name) = lower(:name) ")
    fun extractByName(@Param("name") name: String): Country

    // manual custom query (SQL example)
    @Query(
        "select * from country",
        nativeQuery = true
    )
    fun fetchAll(): Collection<Country>


    // SORTING
    // sorting with JPQL
    @Query("select c from Country c")
    fun findAllCountries(sort: Sort): List<Country>


    // PAGINATION
    // pagination (PSQL)
    @Query("select c from Country c order by c.id")
    fun findAllCountriesWithPagination(pageable: Pageable): List<Country>

    // pagination (SQL)
    @Query(
        "select * from country order by id",
        countQuery = "select count(*) from country",
        nativeQuery = true
    )
    fun findWithNativePagination(pageable: Pageable): List<Country>


    // QUERY PARAMETERS
    // indexed query parameters (JPQL)
    @Query("select c from Country c where c.id = ?1 and c.name = ?2")
    fun fetchByIdAndName(id: Int, name: String): List<Country>

    // native query parameters (SQL)
    @Query(
        "select * from country where id = ?1 and name = ?2",
        nativeQuery = true
    )
    fun fetchByIdAndNameNative(id: Int, name: String): List<Country>


    // named parameters (JPQL)
    @Query("select c from Country c where c.id = :id and c.name = :name")
    fun fetchByIdAndNameNamed(
        @Param("id") id: Int,
        @Param("name") name: String
    ): List<Country>

    // named parameters (SQL)
    @Query(
        "select * from country where id = :id and name = :countryName",
        nativeQuery = true
    )
    fun selectSql(
        @Param("countryName") name: String,
        @Param("id") id: Int
    ): List<Country>


    // Collection parameter
    @Query("select c from Country c where c.name in :names")
    fun selectCollection(
        @Param("names") names: Collection<String>
    ): List<Country>


    // MODIFYING QUERY
    // modifying JPQL
    // Note: needs @Transactional
    @Modifying
    @Query("update Country c set c.name = :name where c.id = :id")
    fun updateCountry(
        @Param("name") name: String,
        @Param("id") id: Int
    )

    // modifying SQL
    // Note: needs @Transactional
    @Modifying
    @Query(
        "update country set name = :name where id = :id",
        nativeQuery = true
    )
    fun updateCountrySQL(
        @Param("name") name: String,
        @Param("id") id: Int
    )


    // INSERT QUERY
    // Note: only native is supported
    @Modifying
    @Query(
        "insert into country (name) values (:name)",
        nativeQuery = true
    )
    fun insertCountry(
        @Param("name") name: String
    )

}

















### main/kotlin/zavanton/ru/demo/repository/CustomCountryRepository.kt
package zavanton.ru.demo.repository

import zavanton.ru.demo.entity.Country

interface CustomCountryRepository {

    // Composite dynamic query
    // JPA Criteria API demo
    fun fetchCountriesByNames(name: Set<String>): List<Country>
}










### main/kotlin/zavanton/ru/demo/repository/CustomCountryRepositoryImpl.kt
package zavanton.ru.demo.repository

import javax.persistence.EntityManager
import javax.persistence.PersistenceContext
import javax.persistence.criteria.CriteriaQuery
import javax.persistence.criteria.Path
import javax.persistence.criteria.Predicate
import javax.persistence.criteria.Root
import zavanton.ru.demo.entity.Country

class CustomCountryRepositoryImpl(
    @PersistenceContext
    private val entityManager: EntityManager
) : CustomCountryRepository {

    override fun fetchCountriesByNames(names: Set<String>): List<Country> {
        val criteriaBuilder = entityManager.criteriaBuilder
        val query: CriteriaQuery<Country> = criteriaBuilder.createQuery(Country::class.java)
        val country: Root<Country> = query.from(Country::class.java)
        val namePath: Path<String> = country.get("name")

        val predicates = mutableListOf<Predicate>()
        names.forEach { name -> predicates.add(criteriaBuilder.like(namePath, name)) }

        query.select(country)
            .where(criteriaBuilder.or(*predicates.toTypedArray()))

        return entityManager.createQuery(query).resultList
    }
}










### main/kotlin/zavanton/ru/demo/controller/MyController.kt
package zavanton.ru.demo.controller

import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort
import org.springframework.data.jpa.domain.JpaSort
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RestController
import zavanton.ru.demo.controller.reponse.CountriesResponse
import zavanton.ru.demo.controller.reponse.CountryResponse
import zavanton.ru.demo.repository.CountryRepository
import zavanton.ru.demo.service.CountryService

@RestController
class MyController(
    private val countryRepository: CountryRepository,
    private val countryService: CountryService,
) {

    @GetMapping("")
    fun home(): CountriesResponse {
        // Sort the findBy query
        return CountriesResponse(
            countries = countryRepository
                .findAll(Sort.by(Sort.Direction.ASC, "name"))
        )
    }

    @GetMapping("/sort/name")
    fun sortByName(): CountriesResponse {
        return CountriesResponse(
            countries = countryRepository
                .findAllCountries(Sort.by("name"))
        )
    }

    @GetMapping("/sort/length")
    fun sortByNameLength(): CountriesResponse {
        return CountriesResponse(
            countries = countryRepository
                .findAllCountries(JpaSort.unsafe("LENGTH(name)"))
        )
    }

    @GetMapping("/pagination")
    fun fetchCountriesWithPagination(): CountriesResponse {
        return CountriesResponse(
            countries = countryRepository.findAllCountriesWithPagination(
                PageRequest.of(0, 2)
            )
        )
    }

    @GetMapping("/pagination/native")
    fun fetchCountriesWithNativePagination(): CountriesResponse {
        return CountriesResponse(
            countries = countryRepository.findWithNativePagination(
                PageRequest.of(0, 2)
            )
        )
    }

    @GetMapping("/params/indexed")
    fun fetchByIdAndName(): CountriesResponse {
        return CountriesResponse(
            countries = countryRepository.fetchByIdAndName(1, "Russia")
        )
    }

    @GetMapping("/params/indexed/native")
    fun fetchByIdAndNameNative(): CountriesResponse {
        return CountriesResponse(
            countries = countryRepository.fetchByIdAndNameNative(1, "Russia")
        )
    }

    @GetMapping("/params/named")
    fun fetchByIdAndNameNamed(): CountriesResponse {
        return CountriesResponse(
            countries = countryRepository.fetchByIdAndNameNamed(1, "Russia")
        )
    }

    @GetMapping("/params/named/native")
    fun fetchByIdAndNameNamedNative(): CountriesResponse {
        return CountriesResponse(
            countries = countryRepository.selectSql(id = 1, name = "Russia")
        )
    }

    @GetMapping("/params/collection")
    fun selectCollection(): CountriesResponse {
        return CountriesResponse(
            countries = countryRepository.selectCollection(listOf("Russia", "Brazil"))
        )
    }

    @GetMapping("/update")
    fun updateCountry(): CountryResponse {
        countryService.updateCountry(name = "RF", id = 1)
        return CountryResponse(
            country = countryRepository.findById(1).get()
        )
    }

    @GetMapping("/update/native")
    fun updateCountryNative(): CountryResponse {
        countryService.updateCountrySQL(name = "RF", id = 1)
        return CountryResponse(
            country = countryRepository.findById(1).get()
        )
    }

    @PostMapping("/insert/{name}")
    fun insertCountry(
        @PathVariable("name") name: String
    ): CountryResponse {
        countryService.insertCountry(name)
        return CountryResponse(
            country = countryRepository.findByName(name)
        )
    }

    @GetMapping("/composite")
    fun compositeCustomQueryDemo(): CountriesResponse {
        return CountriesResponse(
            countries = countryRepository.fetchCountriesByNames(setOf("Russia", "Brazil"))
        )
    }
}










### main/kotlin/zavanton/ru/demo/controller/reponse/CountryResponse.kt
package zavanton.ru.demo.controller.reponse

import zavanton.ru.demo.entity.Country

data class CountryResponse(
    val country: Country
)










### main/kotlin/zavanton/ru/demo/controller/reponse/CountriesResponse.kt
package zavanton.ru.demo.controller.reponse

import zavanton.ru.demo.entity.Country

data class CountriesResponse(
    val countries: List<Country>
)










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










### main/kotlin/zavanton/ru/demo/service/CountryService.kt
package zavanton.ru.demo.service

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import zavanton.ru.demo.repository.CountryRepository

@Service
class CountryService(
    private val countryRepository: CountryRepository
) {

    @Transactional
    fun updateCountry(id: Int, name: String) {
        countryRepository.updateCountry(name, id)
    }

    @Transactional
    fun updateCountrySQL(id: Int, name: String) {
        countryRepository.updateCountrySQL(name, id)
    }

    @Transactional
    fun insertCountry(name: String) {
        countryRepository.insertCountry(name)
    }
}
