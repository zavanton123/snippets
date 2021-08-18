# Java Spring - Company CRUD example (REST API, Thymeleaf, JUnit, Mockito)




### test/kotlin/com/zavanton/company/AppTests.kt
package com.zavanton.company

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class AppTests {

    @Test
    fun contextLoads() {
    }
}










### test/kotlin/com/zavanton/company/repository/CompanyRepositoryTest.kt
package com.zavanton.company.repository

import com.zavanton.company.data.entity.Company
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager

@DataJpaTest
internal class CompanyRepositoryTest {

    @Autowired
    lateinit var entityManager: TestEntityManager

    @Autowired
    lateinit var companyRepository: CompanyRepository

    @BeforeEach
    fun setup() {
        entityManager.clear()
        entityManager.clear()
        entityManager.flush()
    }

    @Test
    fun `test findByName returns a company if it exists in DB`() {
        // mock
        val name = "TestCompany"
        val expectedCompany = Company(name = name)
        entityManager.persist(expectedCompany)
        entityManager.flush()

        // action
        val actualCompanyOptional = companyRepository.findByName(name)

        // verify
        assertTrue(actualCompanyOptional.isPresent)
        assertEquals(expectedCompany, actualCompanyOptional.get())
    }

    @Test
    fun `test findByName returns an empty optional if the company does not exist in DB`() {
        // mock
        val name = "TestCompany"

        // action
        val actualCompanyOptional = companyRepository.findByName(name)

        // verify
        assertFalse(actualCompanyOptional.isPresent)
    }
}










### test/kotlin/com/zavanton/company/controller/CompanyControllerTest.kt
package com.zavanton.company.controller

import com.zavanton.company.data.command.CompanyCommand
import com.zavanton.company.controller.web.CompanyController
import com.zavanton.company.controller.web.CompanyController.Companion.COMPANIES_ATTRIBUTE
import com.zavanton.company.controller.web.CompanyController.Companion.COMPANIES_CREATE_URL
import com.zavanton.company.controller.web.CompanyController.Companion.COMPANIES_LIST_TEMPLATE
import com.zavanton.company.controller.web.CompanyController.Companion.COMPANIES_LIST_URL
import com.zavanton.company.controller.web.CompanyController.Companion.COMPANIES_PROCESS_CREATE_URL
import com.zavanton.company.controller.web.CompanyController.Companion.COMPANY_ATTRIBUTE
import com.zavanton.company.controller.web.CompanyController.Companion.COMPANY_DETAILS_TEMPLATE
import com.zavanton.company.controller.web.CompanyController.Companion.CREATE_COMPANY_FORM_TEMPLATE
import com.zavanton.company.controller.web.CompanyController.Companion.DELETE_COMPANY_FORM_TEMPLATE
import com.zavanton.company.controller.web.CompanyController.Companion.PROCESS_UPDATE_COMPANY_URL
import com.zavanton.company.controller.web.CompanyController.Companion.UPDATE_COMPANY_FORM_TEMPLATE
import com.zavanton.company.service.CompanyService
import com.zavanton.company.util.CompanyNotFoundException
import org.junit.jupiter.api.Test
import org.mockito.ArgumentMatchers.anyLong
import org.mockito.Mockito.`when`
import org.mockito.Mockito.verify
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.boot.test.mock.mockito.MockBean
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.model
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.view

@WebMvcTest(controllers = [CompanyController::class])
class CompanyControllerTest {

    @MockBean
    lateinit var companyService: CompanyService

    @Autowired
    lateinit var mvc: MockMvc

    @Test
    fun showAllCompanies() {
        // mock
        val companies = setOf(
            CompanyCommand(id = 0L, name = "Google"),
            CompanyCommand(id = 1L, name = "Amazon"),
            CompanyCommand(id = 2L, name = "Netflix"),
        )
        `when`(companyService.fetchAllCompanies()).thenReturn(companies)

        // action
        mvc.perform(get(COMPANIES_LIST_URL))
            .andExpect(status().isOk)
            .andExpect(model().attribute(COMPANIES_ATTRIBUTE, companies))
            .andExpect(view().name(COMPANIES_LIST_TEMPLATE))

        // verify
        verify(companyService).fetchAllCompanies()
    }

    @Test
    fun showCreateCompanyForm() {
        // mock
        val company = CompanyCommand()

        // action and verify
        mvc.perform(get(COMPANIES_CREATE_URL))
            .andExpect(status().isOk)
            .andExpect(model().attribute(COMPANY_ATTRIBUTE, company))
            .andExpect(view().name(CREATE_COMPANY_FORM_TEMPLATE))
    }

    @Test
    fun processCreateCompanyForm() {
        // mock
        val company = CompanyCommand(id = 0L, name = "Google")
        val savedCompany = CompanyCommand(id = 0L, name = "Google")
        `when`(companyService.createCompany(company)).thenReturn(savedCompany)

        // action
        mvc.perform(
            post(COMPANIES_PROCESS_CREATE_URL)
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .param("id", company.id.toString())
                .param("name", company.name)
        )
            .andExpect(status().is3xxRedirection)
            .andExpect(view().name("redirect:/companies/0"))

        // verify
        verify(companyService).createCompany(company)
    }

    @Test
    fun showCompanyById() {
        // mock
        val id = 0L
        val company = CompanyCommand(id = id, name = "Google")
        `when`(companyService.fetchCompanyById(anyLong())).thenReturn(company)

        // action
        mvc.perform(get("/companies/$id"))
            .andExpect(status().isOk)
            .andExpect(model().attribute(COMPANY_ATTRIBUTE, company))
            .andExpect(view().name(COMPANY_DETAILS_TEMPLATE))

        // verify
        verify(companyService).fetchCompanyById(anyLong())
    }

    @Test
    fun `test showCompanyById throws exception if company not found`() {
        // mock
        val id = 123L
        `when`(companyService.fetchCompanyById(anyLong())).thenThrow(CompanyNotFoundException::class.java)

        // action
        mvc.perform(get("/companies/$id"))
            .andExpect(status().isNotFound)
            .andExpect(view().name("404"))

        // verify
        verify(companyService).fetchCompanyById(anyLong())
    }

    @Test
    fun processDeleteCompanyForm() {
        // mock
        val id = 0L
        val company = CompanyCommand(id = id, name = "Google")
        `when`(companyService.fetchCompanyById(anyLong())).thenReturn(company)

        // action
        mvc.perform(get("/companies/$id/delete"))
            .andExpect(status().isOk)
            .andExpect(model().attribute(COMPANY_ATTRIBUTE, company))
            .andExpect(view().name(DELETE_COMPANY_FORM_TEMPLATE))

        // verify
        verify(companyService).fetchCompanyById(anyLong())
    }

    @Test
    fun showUpdateCompanyForm() {
        // mock
        val company = CompanyCommand(id = 0L, name = "Google")
        `when`(companyService.fetchCompanyById(anyLong())).thenReturn(company)

        // action
        mvc.perform(get("/companies/${company.id}/update"))
            .andExpect(status().isOk)
            .andExpect(model().attribute(COMPANY_ATTRIBUTE, company))
            .andExpect(view().name(UPDATE_COMPANY_FORM_TEMPLATE))

        // verify
        verify(companyService).fetchCompanyById(anyLong())
    }

    @Test
    fun processUpdateCompanyForm() {
        // mock
        val updatedCompany = CompanyCommand(0L, name = "Google")
        `when`(companyService.updateCompany(updatedCompany)).thenReturn(updatedCompany)

        // action
        mvc.perform(
            post(PROCESS_UPDATE_COMPANY_URL)
                .param("id", updatedCompany.id.toString())
                .param("name", updatedCompany.name)
        )
            .andExpect(status().is3xxRedirection)
            .andExpect(view().name("redirect:/companies/${updatedCompany.id}"))

        // verify
        verify((companyService)).updateCompany(updatedCompany)
    }
}










### test/kotlin/com/zavanton/company/controller/IndexControllerTest.kt
package com.zavanton.company.controller

import com.zavanton.company.controller.web.IndexController
import org.junit.jupiter.api.Test
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.view
import org.springframework.test.web.servlet.setup.MockMvcBuilders

internal class IndexControllerTest {

    private val indexController = IndexController()

    private val mvc = MockMvcBuilders
        .standaloneSetup(indexController)
        .setControllerAdvice(ControllerExceptionHandler())
        .build()

    @Test
    fun `test get request to root returns an index page`() {
        mvc.perform(get("/"))
            .andExpect(view().name("index"))
    }
}










### test/kotlin/com/zavanton/company/controller/api/CompanyApiControllerTest.kt
package com.zavanton.company.controller.api

import com.fasterxml.jackson.databind.ObjectMapper
import com.zavanton.company.controller.ControllerExceptionHandler
import com.zavanton.company.data.dto.CompanyDTO
import com.zavanton.company.data.dto.CompanyListDTO
import com.zavanton.company.service.CompanyApiService
import org.hamcrest.Matchers.equalTo
import org.hamcrest.Matchers.hasSize
import org.junit.jupiter.api.Test
import org.mockito.Mockito.`when`
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.test.web.servlet.setup.MockMvcBuilders

internal class CompanyApiControllerTest {

    private val companyApiService = mock(CompanyApiService::class.java)
    private val companyApiController = CompanyApiController(companyApiService)
    private val mvc = MockMvcBuilders
        .standaloneSetup(companyApiController)
        .setControllerAdvice(ControllerExceptionHandler())
        .build()

    @Test
    fun fetchAllCompanies() {
        // mock
        val companies = listOf(CompanyDTO(), CompanyDTO())
        val companyListDTO = CompanyListDTO(companies)
        `when`(companyApiService.fetchAllCompanies()).thenReturn(companyListDTO)

        // action
        mvc.perform(
            get("/api/companies")
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.companies", hasSize<Any>(2)))

        // verify
        verify(companyApiService).fetchAllCompanies()
    }

    @Test
    fun fetchCompanyById() {
        // mock
        val id = 0L
        val name = "Google"
        val companyDTO = CompanyDTO(id = id, name = name)
        `when`(companyApiService.fetchById(id)).thenReturn(companyDTO)

        // action
        mvc.perform(
            get("/api/companies/$id")
                .accept(MediaType.APPLICATION_JSON)
                .contentType(MediaType.APPLICATION_JSON)
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.id", equalTo(id.toInt())))
            .andExpect(jsonPath("$.name", equalTo(name)))

        // verify
        verify(companyApiService).fetchById(id)
    }

    @Test
    fun createCompany() {
        // mock
        val id = 0L
        val savedId = 10L
        val name = "Google"
        val companyDTO = CompanyDTO(id = id, name = name)
        val createdCompanyDTO = CompanyDTO(id = savedId, name = name)
        `when`(companyApiService.createCompany(companyDTO)).thenReturn(createdCompanyDTO)

        // action
        mvc.perform(
            post("/api/companies")
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .content(ObjectMapper().writeValueAsString(companyDTO))
        )
            .andExpect(status().isCreated)
            .andExpect(jsonPath("$.id", equalTo(savedId.toInt())))
            .andExpect(jsonPath("$.name", equalTo(name)))

        // verify
        verify(companyApiService).createCompany(companyDTO)
    }

    @Test
    fun updateCompany() {
        // mock
        val id = 0L
        val name = "Google"
        val companyDTO = CompanyDTO(id = id, name = name)
        val updatedCompanyDTO = CompanyDTO(id = id, name = name)
        `when`(companyApiService.updateCompany(companyDTO)).thenReturn(updatedCompanyDTO)

        // action
        mvc.perform(
            put("/api/companies/${id}")
                .accept(MediaType.APPLICATION_JSON)
                .contentType(MediaType.APPLICATION_JSON)
                .content(ObjectMapper().writeValueAsString(companyDTO))
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.id", equalTo(id.toInt())))
            .andExpect(jsonPath("$.name", equalTo(name)))
        // verify
        verify(companyApiService).updateCompany(companyDTO)
    }

    @Test
    fun deleteCompany() {
        // mock
        val id = 0L

        // action
        mvc.perform(delete("/api/companies/$id"))
            .andExpect(status().isNoContent)

        // verify
        verify(companyApiService).deleteCompany(id)
    }
}










### test/kotlin/com/zavanton/company/service/CompanyServiceImplTest.kt
package com.zavanton.company.service

import com.zavanton.company.data.command.CompanyCommand
import com.zavanton.company.data.converter.CompanyCommandToEntityConverter
import com.zavanton.company.data.converter.CompanyEntityToCommandConverter
import com.zavanton.company.data.entity.Company
import com.zavanton.company.repository.CompanyRepository
import com.zavanton.company.util.CompanyNotFoundException
import java.util.*
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.anyLong
import org.mockito.ArgumentMatchers.anyString
import org.mockito.Mockito.`when`
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify

internal class CompanyServiceImplTest {

    private val companyRepository = mock(CompanyRepository::class.java)
    private val companyEntityToCommandConverter = mock(CompanyEntityToCommandConverter::class.java)
    private val companyCommandToEntityConverter = mock(CompanyCommandToEntityConverter::class.java)
    private val companyService = CompanyServiceImpl(
        companyRepository,
        companyEntityToCommandConverter,
        companyCommandToEntityConverter
    )

    @Test
    fun `test fetchAllCompanies returns a set of all companies from DB`() {
        // mock
        val company1 = Company(id = 0L, name = "Google")
        val company2 = Company(id = 1L, name = "Facebook")
        val companies = listOf(company1, company2)

        val command1 = CompanyCommand()
        val command2 = CompanyCommand()
        val commands = listOf(command1, command2)

        `when`(companyRepository.findAll()).thenReturn(companies)
        `when`(companyEntityToCommandConverter.convert(company1)).thenReturn(command1)
        `when`(companyEntityToCommandConverter.convert(company2)).thenReturn(command2)

        // action
        val actualCompanies = companyService.fetchAllCompanies()

        // verify
        assertTrue(commands.containsAll(actualCompanies))
        assertTrue(actualCompanies.containsAll(commands))
        verify(companyRepository).findAll()
        verify(companyEntityToCommandConverter).convert(company1)
        verify(companyEntityToCommandConverter).convert(company2)
    }

    @Test
    fun `test fetchCompanyById returns a company if it exists in DB`() {
        // mock
        val id = 0L
        val name = "Google"
        val company = Company(id = id, name = name)
        val command = CompanyCommand(id = id, name = name)
        val companyOptional = Optional.of(company)
        `when`(companyRepository.findById(anyLong())).thenReturn(companyOptional)
        `when`(companyEntityToCommandConverter.convert(company)).thenReturn(command)

        // action
        val actualCompany = companyService.fetchCompanyById(id)

        // verify
        verify(companyRepository).findById(anyLong())
        verify(companyEntityToCommandConverter).convert(company)
        assertEquals(command, actualCompany)
    }

    @Test
    fun `test fetchCompanyById throws a not found exception if the company does not exist in DB`() {
        // mock
        val id = 0L
        val name = "Google"
        val company = Company(id = id, name = name)
        val command = CompanyCommand(id = id, name = name)
        val emptyOptional = Optional.empty<Company>()
        `when`(companyEntityToCommandConverter.convert(company)).thenReturn(command)
        `when`(companyRepository.findById(anyLong())).thenReturn(emptyOptional)

        // action
        assertThrows<CompanyNotFoundException> {
            companyService.fetchCompanyById(id)
        }

        // verify
        verify(companyRepository).findById(anyLong())
        verify(companyEntityToCommandConverter, never()).convert(company)
    }

    @Test
    fun `test fetchCompanyByName returns a company if it exists in DB`() {
        // mock
        val name = "Google"
        val company = Company(id = 0, name = name)
        val command = CompanyCommand(id = 0L, name = name)
        val companyOptional = Optional.of(company)
        `when`(companyRepository.findByName(anyString())).thenReturn(companyOptional)
        `when`(companyEntityToCommandConverter.convert(company)).thenReturn(command)

        // action
        val actual = companyService.fetchCompanyByName(name)

        // verify
        verify(companyRepository).findByName(anyString())
        verify(companyEntityToCommandConverter).convert(company)
        assertEquals(command, actual)
    }

    @Test
    fun `test fetchCompanyByName throws a not found exception if the company does not exist in DB`() {
        // mock
        val name = "Google"
        val company = Company()
        val command = CompanyCommand(id = 0L, name = name)
        val emptyOptional = Optional.empty<Company>()
        `when`(companyRepository.findByName(anyString())).thenReturn(emptyOptional)
        `when`(companyEntityToCommandConverter.convert(company)).thenReturn(command)

        // action
        assertThrows<CompanyNotFoundException> {
            companyService.fetchCompanyByName(name)
        }

        // verify
        verify(companyRepository).findByName(anyString())
        verify(companyEntityToCommandConverter, never()).convert(company)
    }

    @Test
    fun `test createCompany saves a company to DB`() {
        // mock
        val id = 0L
        val name = "Google"
        val command = CompanyCommand(id = id, name = name)
        val company = Company(id = id, name = name)
        val savedCompany = Company(id = id, name = name)
        val savedCommand = CompanyCommand(id = id, name = name)
        `when`(companyCommandToEntityConverter.convert(command)).thenReturn(company)
        `when`(companyRepository.save(any(Company::class.java))).thenReturn(savedCompany)
        `when`(companyEntityToCommandConverter.convert(savedCompany)).thenReturn(savedCommand)

        // action
        val actual = companyService.createCompany(command)

        // verify
        verify(companyCommandToEntityConverter).convert(command)
        verify(companyRepository).save(any(Company::class.java))
        verify(companyEntityToCommandConverter).convert(savedCompany)
        assertEquals(command, actual)
    }

    @Test
    fun `test updateCompany updates the company`() {
        // mock
        val id = 0L
        val name = "Google"
        val updatedName = "Amazon"
        val command = CompanyCommand(id = id, name = name)
        val company = Company(id = id, name = name)
        val updatedCompany = Company(id = id, name = updatedName)
        val updatedCommand = CompanyCommand(id = id, name = updatedName)
        `when`(companyCommandToEntityConverter.convert(command)).thenReturn(company)
        `when`(companyRepository.save(any(Company::class.java))).thenReturn(updatedCompany)
        `when`(companyEntityToCommandConverter.convert(updatedCompany)).thenReturn(updatedCommand)

        // action
        val actual = companyService.createCompany(command)

        // verify
        verify(companyCommandToEntityConverter).convert(command)
        verify(companyRepository).save(any(Company::class.java))
        verify(companyEntityToCommandConverter).convert(updatedCompany)
        assertEquals(updatedCommand, actual)
    }

    @Test
    fun `test deleteCompany deletes the company`() {
        // mock
        val company = Company(id = 0L, name = "Google")

        // action
        companyService.deleteCompany(company.id)

        // verify
        verify(companyRepository).deleteById(company.id)
    }
}










### main/resources/schema.sql
insert into company (name)
values ('Facebook');
insert into company (name)
values ('Amazon');
insert into company (name)
values ('Apple');
insert into company (name)
values ('Netflix');
insert into company (name)
values ('Google');










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











### main/resources/templates/404.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Not Found</title>
</head>
<body>
<h1>Company Not Found</h1>
</body>
</html>










### main/resources/templates/error.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Error</title>
</head>
<body>
<h1>Bad Request Error</h1>
</body>
</html>










### main/resources/templates/500.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Server Error</title>
</head>
<body>
<h1>Server Error</h1>
<p>Try again later...</p>
</body>
</html>










### main/resources/templates/index.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Home</title>
</head>
<body>
<h1>Home</h1>

<p><a th:href="@{/companies}">Go to companies</a></p>
<p><a th:href="@{/companies/create}">Create a new company</a></p>

</body>
</html>










### main/resources/templates/companies/delete_company.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Delete Company</title>
</head>
<body>
<h1>Delete Company</h1>

<form th:action="@{/companies/process_delete}" method="post">
    <input type="hidden" th:field="${company.id}"/>

    <label th:text="'Are you sure you want to delete ' + ${company.name} + '?'"></label><br/>

    <input type="submit" value="Delete"/>
</form>

</body>
</html>










### main/resources/templates/companies/company_details.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Company Details</title>
</head>
<body>
<h1>Company Details</h1>

<table th:object="${company}">
    <tr>
        <th>Id</th>
        <th>Name</th>
    </tr>
    <tr>
        <td th:text="*{id}">Id</td>
        <td th:text="*{name}">Name</td>
    </tr>
</table>

<br/>
<br/>
<br/>

<p><a th:href="@{/companies/{id}/delete(id=${company.id})}">Delete</a></p>
<p><a th:href="@{/companies/{id}/update(id=${company.id})}">Update</a></p>
<br />

<p><a th:href="@{/companies}">Go to companies</a></p>
<p><a th:href="@{/companies/create}">Create a new company</a></p>

</body>
</html>










### main/resources/templates/companies/companies_list.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>All Companies</title>
</head>
<body>
<h1>All Companies</h1>

<p><a th:href="@{/companies/create}">Create a new company</a></p>

<ul th:each="company : ${companies}">
    <li>
        <a th:href="@{/companies/{id}(id=${company.id})}"
           th:text="${company.name}">
            Company Name
        </a>
    </li>
</ul>

</body>
</html>










### main/resources/templates/companies/create_company.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Create a Company</title>
</head>
<body>
<h1>Create a Company</h1>

<p><a th:href="@{/companies}">Go to companies</a></p>

<form th:action="@{/companies/process_create}" method="post">
    <input type="hidden" th:field="${company.id}"/>

    <label>Name:</label>
    <br/>

    <input type="text" th:field="${company.name}"/>
    <br/>

    <input type="submit" value="Save"/>
</form>

</body>
</html>










### main/resources/templates/companies/update_company.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Update Company</title>
</head>
<body>
<h1>Update Company</h1>

<form th:object="${company}" th:action="@{/companies/process_update}" method="post">
    <input type="hidden" th:field="*{id}"/>

    <label>Name:</label>
    <br/>
    <input type="text" th:field="*{name}" th:value="*{name}"/>
    <br/>

    <input type="submit" value="Save"/>
</form>

</body>
</html>










### main/resources/postman/CompanyApi.postman_collection.json
{
	"info": {
		"_postman_id": "3098e363-39c8-4622-9935-271ff77b8462",
		"name": "CompanyApi",
		"schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
	},
	"item": [
		{
			"name": "localhost:9999/api/companies",
			"request": {
				"method": "GET",
				"header": [],
				"url": {
					"raw": "localhost:9999/api/companies",
					"host": [
						"localhost"
					],
					"port": "9999",
					"path": [
						"api",
						"companies"
					]
				}
			},
			"response": []
		},
		{
			"name": "localhost:9999/api/companies/1",
			"request": {
				"method": "GET",
				"header": [],
				"url": {
					"raw": "localhost:9999/api/companies/1",
					"host": [
						"localhost"
					],
					"port": "9999",
					"path": [
						"api",
						"companies",
						"1"
					]
				}
			},
			"response": []
		},
		{
			"name": "localhost:9999/api/companies Copy",
			"request": {
				"method": "POST",
				"header": [],
				"body": {
					"mode": "raw",
					"raw": "{\n    \"name\": \"Hello\"\n}",
					"options": {
						"raw": {
							"language": "json"
						}
					}
				},
				"url": {
					"raw": "localhost:9999/api/companies",
					"host": [
						"localhost"
					],
					"port": "9999",
					"path": [
						"api",
						"companies"
					]
				}
			},
			"response": []
		},
		{
			"name": "localhost:9999/api/companies Copy 2",
			"request": {
				"method": "PUT",
				"header": [],
				"body": {
					"mode": "raw",
					"raw": "{\n    \"name\": \"Hello\"\n}",
					"options": {
						"raw": {
							"language": "json"
						}
					}
				},
				"url": {
					"raw": "localhost:9999/api/companies/1",
					"host": [
						"localhost"
					],
					"port": "9999",
					"path": [
						"api",
						"companies",
						"1"
					]
				}
			},
			"response": []
		},
		{
			"name": "localhost:9999/api/companies Copy 3",
			"request": {
				"method": "DELETE",
				"header": [],
				"body": {
					"mode": "raw",
					"raw": "",
					"options": {
						"raw": {
							"language": "json"
						}
					}
				},
				"url": {
					"raw": "localhost:9999/api/companies/1",
					"host": [
						"localhost"
					],
					"port": "9999",
					"path": [
						"api",
						"companies",
						"1"
					]
				}
			},
			"response": []
		}
	]
}









### main/kotlin/com/zavanton/company/App.kt
package com.zavanton.company

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
	runApplication<App>(*args)
}










### main/kotlin/com/zavanton/company/repository/CompanyRepository.kt
package com.zavanton.company.repository

import com.zavanton.company.data.entity.Company
import java.util.*
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository

@Repository
interface CompanyRepository : CrudRepository<Company, Long> {

    fun findByName(name: String): Optional<Company>
}










### main/kotlin/com/zavanton/company/util/Utils.kt
package com.zavanton.company.util

const val EMPTY = ""










### main/kotlin/com/zavanton/company/util/Exceptions.kt
package com.zavanton.company.util

class CompanyNotFoundException(message: String = EMPTY) : RuntimeException(message)

class CompanyNotFoundApiException(message: String = EMPTY) : RuntimeException(message)










### main/kotlin/com/zavanton/company/data/mapper/CompanyMapperImpl.kt
package com.zavanton.company.data.mapper

import com.zavanton.company.data.dto.CompanyDTO
import com.zavanton.company.data.entity.Company
import org.springframework.stereotype.Component

@Component
class CompanyMapperImpl : CompanyMapper {

    override fun mapEntityToDto(company: Company): CompanyDTO {
        return CompanyDTO(
            id = company.id,
            name = company.name
        )
    }

    override fun mapDtoToEntity(companyDTO: CompanyDTO): Company {
        return Company(
            id = companyDTO.id,
            name = companyDTO.name
        )
    }

}









### main/kotlin/com/zavanton/company/data/mapper/CompanyMapper.kt
package com.zavanton.company.data.mapper

import com.zavanton.company.data.dto.CompanyDTO
import com.zavanton.company.data.entity.Company

interface CompanyMapper {

    fun mapEntityToDto(company: Company): CompanyDTO
    fun mapDtoToEntity(companyDTO: CompanyDTO): Company
}










### main/kotlin/com/zavanton/company/data/command/CompanyCommand.kt
package com.zavanton.company.data.command

import com.zavanton.company.util.EMPTY

data class CompanyCommand(
    val id: Long = 0L,
    val name: String = EMPTY
)










### main/kotlin/com/zavanton/company/data/entity/Company.kt
package com.zavanton.company.data.entity

import com.zavanton.company.util.EMPTY
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
data class Company(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    var name: String = EMPTY
)










### main/kotlin/com/zavanton/company/data/converter/CompanyConverter.kt
package com.zavanton.company.data.converter

import com.zavanton.company.data.command.CompanyCommand
import com.zavanton.company.data.entity.Company
import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component

@Component
class CompanyEntityToCommandConverter : Converter<Company, CompanyCommand> {

    override fun convert(source: Company): CompanyCommand {
        return CompanyCommand(
            id = source.id,
            name = source.name
        )
    }
}

@Component
class CompanyCommandToEntityConverter : Converter<CompanyCommand, Company> {

    override fun convert(source: CompanyCommand): Company {
        return Company(
            id = source.id,
            name = source.name
        )
    }
}










### main/kotlin/com/zavanton/company/data/dto/CompanyDTO.kt
package com.zavanton.company.data.dto

import com.zavanton.company.util.EMPTY

data class CompanyDTO(
    var id: Long = 0L,
    var name: String = EMPTY
)










### main/kotlin/com/zavanton/company/data/dto/CompanyListDTO.kt
package com.zavanton.company.data.dto

data class CompanyListDTO(
    val companies: List<CompanyDTO>
)










### main/kotlin/com/zavanton/company/controller/ControllerExceptionHandler.kt
package com.zavanton.company.controller

import com.zavanton.company.util.CompanyNotFoundApiException
import com.zavanton.company.util.CompanyNotFoundException
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ControllerAdvice
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.servlet.ModelAndView

@ControllerAdvice
class ControllerExceptionHandler {

    @ResponseStatus(HttpStatus.NOT_FOUND)
    @ExceptionHandler(CompanyNotFoundException::class)
    fun handleCompanyNotFoundException(
        exception: CompanyNotFoundException
    ): ModelAndView {
        return ModelAndView("404", mutableMapOf("exception" to exception))
    }

    @ResponseStatus(HttpStatus.NOT_FOUND)
    @ExceptionHandler(CompanyNotFoundApiException::class)
    fun handleCompanyNotFoundApiException(
        exception: CompanyNotFoundApiException
    ): String {
        return exception.message ?: "company not found error"
    }

    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    @ExceptionHandler(Exception::class)
    fun handleException(): String {
        return "500"
    }
}










### main/kotlin/com/zavanton/company/controller/web/CompanyController.kt
package com.zavanton.company.controller.web

import com.zavanton.company.data.command.CompanyCommand
import com.zavanton.company.service.CompanyService
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.ModelAttribute
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping

@Controller
class CompanyController(
    private val companyService: CompanyService
) {

    companion object {
        const val ID_PATH_VARIABLE = "id"

        const val COMPANIES_ATTRIBUTE = "companies"
        const val COMPANY_ATTRIBUTE = "company"

        const val REDIRECT_TO = "redirect:"
        const val COMPANIES_LIST_URL = "/companies"
        const val COMPANIES_CREATE_URL = "/companies/create"
        const val COMPANIES_PROCESS_CREATE_URL = "/companies/process_create"
        const val COMPANIES_ID_URL = "/companies/{id}"
        const val DELETE_COMPANY_FORM_URL = "/companies/{id}/delete"
        const val PROCESS_DELETE_COMPANY_URL = "/companies/process_delete"
        const val UPDATE_COMPANY_FORM_URL = "/companies/{id}/update"
        const val PROCESS_UPDATE_COMPANY_URL = "/companies/process_update"

        const val COMPANIES_LIST_TEMPLATE = "companies/companies_list"
        const val COMPANY_DETAILS_TEMPLATE = "companies/company_details"
        const val CREATE_COMPANY_FORM_TEMPLATE = "companies/create_company"
        const val DELETE_COMPANY_FORM_TEMPLATE = "companies/delete_company"
        const val UPDATE_COMPANY_FORM_TEMPLATE = "companies/update_company"
    }

    @GetMapping(COMPANIES_LIST_URL)
    fun showAllCompanies(
        model: Model
    ): String {
        val companies = companyService.fetchAllCompanies()
        model.addAttribute(COMPANIES_ATTRIBUTE, companies)
        return COMPANIES_LIST_TEMPLATE
    }

    @GetMapping(COMPANIES_CREATE_URL)
    fun showCreateCompanyForm(
        model: Model
    ): String {
        val company = CompanyCommand()
        model.addAttribute(COMPANY_ATTRIBUTE, company)
        return CREATE_COMPANY_FORM_TEMPLATE
    }

    @PostMapping(COMPANIES_PROCESS_CREATE_URL)
    fun processCreateCompanyForm(
        @ModelAttribute company: CompanyCommand
    ): String {
        val savedCompany = companyService.createCompany(company)
        return REDIRECT_TO + COMPANIES_LIST_URL + "/${savedCompany.id}"
    }

    @GetMapping(COMPANIES_ID_URL)
    fun showCompanyById(
        @PathVariable(ID_PATH_VARIABLE) id: Long,
        model: Model
    ): String {
        val company = companyService.fetchCompanyById(id)
        model.addAttribute(COMPANY_ATTRIBUTE, company)
        return COMPANY_DETAILS_TEMPLATE
    }

    @GetMapping(DELETE_COMPANY_FORM_URL)
    fun showDeleteCompanyForm(
        @PathVariable(ID_PATH_VARIABLE) id: Long,
        model: Model
    ): String {
        val company = companyService.fetchCompanyById(id)
        model.addAttribute(COMPANY_ATTRIBUTE, company)
        return DELETE_COMPANY_FORM_TEMPLATE
    }

    @PostMapping(PROCESS_DELETE_COMPANY_URL)
    fun processDeleteCompanyForm(
        @ModelAttribute company: CompanyCommand
    ): String {
        companyService.deleteCompany(company.id)
        return REDIRECT_TO + COMPANIES_LIST_URL
    }

    @GetMapping(UPDATE_COMPANY_FORM_URL)
    fun showUpdateCompanyForm(
        @PathVariable(ID_PATH_VARIABLE) id: Long,
        model: Model
    ): String {
        val company = companyService.fetchCompanyById(id)
        model.addAttribute(COMPANY_ATTRIBUTE, company)
        return UPDATE_COMPANY_FORM_TEMPLATE
    }

    @PostMapping(PROCESS_UPDATE_COMPANY_URL)
    fun processUpdateCompanyForm(
        @ModelAttribute company: CompanyCommand
    ): String {
        val updatedCompany = companyService.updateCompany(company)
        return REDIRECT_TO + COMPANIES_LIST_URL + "/${updatedCompany.id}"
    }
}










### main/kotlin/com/zavanton/company/controller/web/CustomErrorController.kt
package com.zavanton.company.controller.web

import org.springframework.boot.web.servlet.error.ErrorController
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus

@Controller
class CustomErrorController : ErrorController {

    companion object {
        const val ERROR_URL = "/error"
    }

    @ResponseStatus(HttpStatus.BAD_REQUEST)
    @RequestMapping(ERROR_URL)
    fun processGenericError(): String {
        return "error"
    }
}










### main/kotlin/com/zavanton/company/controller/web/IndexController.kt
package com.zavanton.company.controller.web

import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.GetMapping

@Controller
class IndexController {

    @GetMapping("/")
    fun home(): String {
        return "index"
    }
}










### main/kotlin/com/zavanton/company/controller/api/CompanyApiController.kt
package com.zavanton.company.controller.api

import com.zavanton.company.data.dto.CompanyDTO
import com.zavanton.company.data.dto.CompanyListDTO
import com.zavanton.company.service.CompanyApiService
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api")
class CompanyApiController(
    private val companyApiService: CompanyApiService
) {

    @GetMapping("/companies")
    @ResponseStatus(HttpStatus.OK)
    fun fetchAllCompanies(): CompanyListDTO {
        return companyApiService.fetchAllCompanies()
    }

    @GetMapping("/companies/{id}")
    fun fetchCompanyById(
        @PathVariable("id") id: Long
    ): CompanyDTO {
        return companyApiService.fetchById(id)
    }

    @PostMapping("/companies")
    @ResponseStatus(HttpStatus.CREATED)
    fun createCompany(
        @RequestBody companyDTO: CompanyDTO
    ): CompanyDTO {
        return companyApiService.createCompany(companyDTO)
    }

    @PutMapping("/companies/{id}")
    @ResponseStatus(HttpStatus.OK)
    fun updateCompany(
        @PathVariable("id") id: Long,
        @RequestBody companyDto: CompanyDTO
    ): CompanyDTO {
        companyDto.id = id
        return companyApiService.updateCompany(companyDto)
    }


    @DeleteMapping("/companies/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    fun deleteCompany(
        @PathVariable("id") id: Long
    ) {
        return companyApiService.deleteCompany(id)
    }

}










### main/kotlin/com/zavanton/company/service/CompanyServiceImpl.kt
package com.zavanton.company.service

import com.zavanton.company.data.command.CompanyCommand
import com.zavanton.company.data.converter.CompanyCommandToEntityConverter
import com.zavanton.company.data.converter.CompanyEntityToCommandConverter
import com.zavanton.company.repository.CompanyRepository
import com.zavanton.company.util.CompanyNotFoundException
import org.springframework.stereotype.Service

@Service
class CompanyServiceImpl(
    private val companyRepository: CompanyRepository,
    private val companyEntityToCommandConverter: CompanyEntityToCommandConverter,
    private val companyCommandToEntityConverter: CompanyCommandToEntityConverter
) : CompanyService {

    override fun fetchAllCompanies(): Set<CompanyCommand> {
        return companyRepository.findAll()
            .map { companyEntityToCommandConverter.convert(it) }
            .toSet()
    }

    override fun fetchCompanyById(id: Long): CompanyCommand {
        val companyOptional = companyRepository.findById(id)
        return if (companyOptional.isPresent) {
            companyEntityToCommandConverter.convert(companyOptional.get())
        } else {
            throw CompanyNotFoundException("Company with id $id does not exist")
        }
    }

    override fun fetchCompanyByName(name: String): CompanyCommand {
        val companyOptional = companyRepository.findByName(name)
        return if (companyOptional.isPresent) {
            companyEntityToCommandConverter.convert(companyOptional.get())
        } else {
            throw CompanyNotFoundException("Company with name $name does not exist")
        }
    }

    override fun createCompany(command: CompanyCommand): CompanyCommand {
        val company = companyCommandToEntityConverter.convert(command)
        val savedCompany = companyRepository.save(company)
        return companyEntityToCommandConverter.convert(savedCompany)
    }

    override fun updateCompany(company: CompanyCommand): CompanyCommand {
        val command = companyCommandToEntityConverter.convert(company)
        val savedCompany = companyRepository.save(command)
        return companyEntityToCommandConverter.convert(savedCompany)
    }

    override fun patchCompany(company: CompanyCommand): CompanyCommand {
        // todo zavanton - replace by patch logic
        val command = companyCommandToEntityConverter.convert(company)
        val savedCompany = companyRepository.save(command)
        return companyEntityToCommandConverter.convert(savedCompany)
    }

    override fun deleteCompany(id: Long) {
        companyRepository.deleteById(id)
    }
}










### main/kotlin/com/zavanton/company/service/CompanyApiService.kt
package com.zavanton.company.service

import com.zavanton.company.data.dto.CompanyDTO
import com.zavanton.company.data.dto.CompanyListDTO

interface CompanyApiService {

    fun fetchAllCompanies(): CompanyListDTO

    fun fetchById(id: Long): CompanyDTO

    fun createCompany(companyDTO: CompanyDTO): CompanyDTO

    fun updateCompany(companyDTO: CompanyDTO): CompanyDTO

    fun deleteCompany(id: Long)
}










### main/kotlin/com/zavanton/company/service/CompanyApiServiceImpl.kt
package com.zavanton.company.service

import com.zavanton.company.data.dto.CompanyDTO
import com.zavanton.company.data.dto.CompanyListDTO
import com.zavanton.company.data.mapper.CompanyMapper
import com.zavanton.company.repository.CompanyRepository
import com.zavanton.company.util.CompanyNotFoundApiException
import org.springframework.stereotype.Service

@Service
class CompanyApiServiceImpl(
    private val companyRepository: CompanyRepository,
    private val mapper: CompanyMapper
) : CompanyApiService {

    override fun fetchAllCompanies(): CompanyListDTO {
        return CompanyListDTO(companyRepository.findAll()
            .map { mapper.mapEntityToDto(it) })
    }

    override fun fetchById(id: Long): CompanyDTO {
        val companyOptional = companyRepository.findById(id)
        return if (companyOptional.isPresent) {
            mapper.mapEntityToDto(companyOptional.get())
        } else {
            throw CompanyNotFoundApiException()
        }
    }

    override fun createCompany(companyDTO: CompanyDTO): CompanyDTO {
        val company = mapper.mapDtoToEntity(companyDTO)
        val savedCompany = companyRepository.save(company)
        return mapper.mapEntityToDto(savedCompany)
    }

    override fun updateCompany(companyDTO: CompanyDTO): CompanyDTO {
        val company = mapper.mapDtoToEntity(companyDTO)
        val savedCompany = companyRepository.save(company)
        return mapper.mapEntityToDto(savedCompany)
    }

    override fun deleteCompany(id: Long) {
        companyRepository.deleteById(id)
    }
}










### main/kotlin/com/zavanton/company/service/CompanyService.kt
package com.zavanton.company.service

import com.zavanton.company.data.command.CompanyCommand

interface CompanyService {

    fun fetchAllCompanies(): Set<CompanyCommand>

    fun fetchCompanyById(id: Long): CompanyCommand

    fun fetchCompanyByName(name: String): CompanyCommand

    fun createCompany(command: CompanyCommand): CompanyCommand

    fun updateCompany(company: CompanyCommand): CompanyCommand

    fun patchCompany(company: CompanyCommand): CompanyCommand

    fun deleteCompany(id: Long)
}
