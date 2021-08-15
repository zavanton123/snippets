# Java Spring - Testing with JUnit and Mockito



### test/kotlin/ru/zavanton/demo/MyDemoApplicationTests.kt
package ru.zavanton.demo

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class MyDemoApplicationTests {

    @Test
    fun contextLoads() {
    }
}










### test/kotlin/ru/zavanton/demo/controller/IndexControllerTest.kt
package ru.zavanton.demo.controller

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers.eq
import org.mockito.Mockito.`when`
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.view
import org.springframework.test.web.servlet.setup.MockMvcBuilders
import org.springframework.ui.Model
import ru.zavanton.demo.entity.Recipe
import ru.zavanton.demo.service.RecipeService

internal class IndexControllerTest {

    private val recipeService = mock(RecipeService::class.java)
    private val model = mock(Model::class.java)
    private val indexController = IndexController(recipeService)

    @Test
    fun `test index without argument captor`() {
        // mock
        val recipe = Recipe()
        val expected = mutableSetOf(recipe)
        `when`(recipeService.fetchRecipes()).thenReturn(expected)

        // action
        val template = indexController.index(model)

        // verify
        assertEquals("index", template)
        verify(recipeService).fetchRecipes()
        verify(model).addAttribute("recipes", expected)
    }

    @Test
    fun `test index with argument captor`() {
        // mock
        val recipe1 = Recipe()
        val recipe2 = Recipe()
        val expected = mutableSetOf(recipe1, recipe2)
        `when`(recipeService.fetchRecipes()).thenReturn(expected)

        val captor: ArgumentCaptor<Set<*>> = ArgumentCaptor.forClass(Set::class.java)

        // action
        val template = indexController.index(model)

        // verify
        assertEquals("index", template)
        verify(recipeService).fetchRecipes()
        verify(model).addAttribute(eq("recipes"), captor.capture())
        assertEquals(2, captor.value.size)
    }

    @Test
    fun `test index with mock mvc`() {
        val mockMvc = MockMvcBuilders.standaloneSetup(indexController).build()

        mockMvc.perform(get("/"))
            .andExpect(status().isOk)
            .andExpect(view().name("index"))
    }
}










### test/kotlin/ru/zavanton/demo/repo/CategoryRepoIntegrationTest.kt
package ru.zavanton.demo.repo

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import ru.zavanton.demo.entity.Category

@DataJpaTest
class CategoryRepoIntegrationTest {

    @Autowired
    lateinit var categoryRepo: CategoryRepo

    @BeforeEach
    fun setup() {
        val category = Category()
        category.title = "custom"
        categoryRepo.save(category)
    }

    @Test
    fun `test find by title`() {
        val expected = "custom"
        val optional = categoryRepo.findByTitle(expected)
        assertEquals(expected, optional.get().title)
    }
}










### test/kotlin/ru/zavanton/demo/entity/CategoryTest.kt
package ru.zavanton.demo.entity

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

internal class CategoryTest {

    private lateinit var category: Category

    @BeforeEach
    fun before() {
        category = Category()
    }

    @Test
    fun setTitle() {
        val expected = "hello"
        category.title = expected
        assertEquals(expected, category.title)
    }
}










### test/kotlin/ru/zavanton/demo/service/RecipeServiceImplTest.kt
package ru.zavanton.demo.service

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.mockito.Mockito.`when`
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import ru.zavanton.demo.entity.Recipe
import ru.zavanton.demo.repo.RecipeRepo

internal class RecipeServiceImplTest {

    private val recipeRepo = mock(RecipeRepo::class.java)
    private val recipeService = RecipeServiceImpl(recipeRepo)

//    // to avoid having to use backticks for "when"
//    fun <T> whenever(methodCall: T): OngoingStubbing<T> =
//        Mockito.`when`(methodCall)

    @Test
    fun fetchRecipes() {
        // mock
        val recipe = Recipe()
        val expected = mutableSetOf(recipe)
        // whenever(recipeRepo.findAll()).thenReturn(expected)
        `when`(recipeRepo.findAll()).thenReturn(expected)

        // action
        val actual = recipeService.fetchRecipes()

        // verify
        assertEquals(expected, actual)
        verify(recipeRepo).findAll()
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











### main/resources/templates/index.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Home</title>
</head>
<body>
<h1>Home</h1>
<table>
    <thead>
    <tr>
        <th>Id</th>
        <th>Contents</th>
        <th>Difficulty</th>
    </tr>
    </thead>
    <tbody>
    <tr th:each="recipe : ${recipes}">
        <td th:text="${recipe.id}">Id</td>
        <td th:text="${recipe.contents}">Contents</td>
        <td th:text="${recipe.difficulty}">Difficulty</td>
    </tr>
    </tbody>
</table>
</body>
</html>










### main/kotlin/ru/zavanton/demo/MyDemoApplication.kt
package ru.zavanton.demo

import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import ru.zavanton.demo.entity.Ingredient
import ru.zavanton.demo.entity.UnitOfMeasure

@SpringBootApplication
class MyDemoApplication

private val log = LoggerFactory.getLogger("main")

fun main(args: Array<String>) {
    val context = runApplication<MyDemoApplication>(*args)
}










### main/kotlin/ru/zavanton/demo/startup/MyRunner.kt
package ru.zavanton.demo.startup

import org.slf4j.LoggerFactory
import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component
import ru.zavanton.demo.entity.*
import ru.zavanton.demo.repo.RecipeRepo

@Component
class MyRunner(
    private val recipeRepo: RecipeRepo
) : CommandLineRunner {

    private val log = LoggerFactory.getLogger(MyRunner::class.java)

    override fun run(vararg args: String?) {
        val unit1 = UnitOfMeasure()
        unit1.description = "unit1"

        val unit2 = UnitOfMeasure()
        unit2.description = "unit2"

        val ingredient1 = Ingredient()
        ingredient1.unit = unit1
        ingredient1.name = "ingredient1"

        val recipe1 = Recipe()
        recipe1.difficulty = Difficulty.HARD
        recipe1.contents = "recipe 1"
        recipe1.addIngredient(ingredient1)

        val category1 = Category()
        category1.title = "category1"
        val category2 = Category()
        category2.title = "category2"

        recipe1.addCategory(category1)
        recipe1.addCategory(category2)

        val note1 = Note()
        note1.recipeDesc = "note1"
        recipe1.addNote(note1)

        recipeRepo.save(recipe1)

        log.info("zavanton - initial data saved...")
    }
}










### main/kotlin/ru/zavanton/demo/controller/IndexController.kt
package ru.zavanton.demo.controller

import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import ru.zavanton.demo.service.RecipeService

@Controller
class IndexController(
    private val recipeService: RecipeService
) {

    @GetMapping("", "/", "/index.html")
    fun index(
        model: Model
    ): String {
        val recipes = recipeService.fetchRecipes()
        model.addAttribute("recipes", recipes)
        return "index"
    }
}










### main/kotlin/ru/zavanton/demo/repo/UnitOfMeasureRepo.kt
package ru.zavanton.demo.repo

import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.UnitOfMeasure

@Repository
interface UnitOfMeasureRepo : CrudRepository<UnitOfMeasure, Long>{
}










### main/kotlin/ru/zavanton/demo/repo/RecipeRepo.kt
package ru.zavanton.demo.repo

import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Recipe

@Repository
interface RecipeRepo : CrudRepository<Recipe, Long>{
}










### main/kotlin/ru/zavanton/demo/repo/NoteRepo.kt
package ru.zavanton.demo.repo

import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Note

@Repository
interface NoteRepo : CrudRepository<Note, Long> {
}










### main/kotlin/ru/zavanton/demo/repo/IngredientRepo.kt
package ru.zavanton.demo.repo

import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Ingredient

@Repository
interface IngredientRepo : CrudRepository<Ingredient, Long>{
}










### main/kotlin/ru/zavanton/demo/repo/CategoryRepo.kt
package ru.zavanton.demo.repo

import java.util.*
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Category

@Repository
interface CategoryRepo : CrudRepository<Category, Long> {

    fun findByTitle(title: String): Optional<Category>
}










### main/kotlin/ru/zavanton/demo/entity/UnitOfMeasure.kt
package ru.zavanton.demo.entity

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id

@Entity
class UnitOfMeasure(
    @Id
    @GeneratedValue
    val id: Long,

    @Column(name = "unit_desc")
    var description: String
) {
    constructor() : this(0, "")
}










### main/kotlin/ru/zavanton/demo/entity/Note.kt
package ru.zavanton.demo.entity

import javax.persistence.*

@Entity
class Note(
    @Id
    @GeneratedValue
    val id: Long,

    @Lob
    var recipeDesc: String,

    @OneToOne
    var recipe: Recipe? = null
) {
    constructor() : this(0, "")

    fun addRecipe(recipe: Recipe) {
        this.recipe = recipe
        recipe.note = this
    }
}










### main/kotlin/ru/zavanton/demo/entity/Ingredient.kt
package ru.zavanton.demo.entity

import javax.persistence.*

@Entity
class Ingredient(
    @Id
    @GeneratedValue
    val id: Long,

    @Column(name = "ingredient_name")
    var name: String,

    @OneToOne(fetch = FetchType.EAGER, cascade = [CascadeType.ALL])
    var unit: UnitOfMeasure? = null,

    @ManyToOne
    var recipe: Recipe? = null
) {
    constructor() : this(0, "")
}









### main/kotlin/ru/zavanton/demo/entity/Difficulty.kt
package ru.zavanton.demo.entity

enum class Difficulty {
    EASY, NORMAL, HARD
}










### main/kotlin/ru/zavanton/demo/entity/Recipe.kt
package ru.zavanton.demo.entity

import javax.persistence.*

@Entity
class Recipe(
    @Id
    @GeneratedValue
    val id: Long,

    @Lob
    @Column(name = "recipe_contents")
    var contents: String,

    @OneToOne(cascade = [CascadeType.ALL])
    var note: Note? = null,

    @OneToMany(mappedBy = "recipe", cascade = [CascadeType.ALL])
    val ingredients: MutableSet<Ingredient> = mutableSetOf(),

    @Enumerated(EnumType.STRING)
    var difficulty: Difficulty = Difficulty.NORMAL,

    @ManyToMany(cascade = [CascadeType.ALL])
    @JoinTable(
        name = "recipe_category",
        joinColumns = [JoinColumn(name = "recipe_id")],
        inverseJoinColumns = [JoinColumn(name = "category_id")]
    )
    val categories: MutableSet<Category> = mutableSetOf()
) {
    constructor() : this(0, "")

    fun addNote(note: Note) {
        this.note = note
        note.recipe = this
    }

    fun addIngredient(ingredient: Ingredient) {
        ingredient.recipe = this
        ingredients.add(ingredient)
    }

    fun addCategory(category: Category) {
        categories.add(category)
        category.recipes.add(this)
    }
}










### main/kotlin/ru/zavanton/demo/entity/Category.kt
package ru.zavanton.demo.entity

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.ManyToMany

@Entity
class Category(
    @Id
    @GeneratedValue
    val id: Long,

    var title: String,

    @ManyToMany(mappedBy = "categories")
    val recipes: MutableSet<Recipe> = mutableSetOf()
) {
    constructor() : this(0, "")
}










### main/kotlin/ru/zavanton/demo/service/RecipeServiceImpl.kt
package ru.zavanton.demo.service

import org.springframework.stereotype.Service
import ru.zavanton.demo.entity.Recipe
import ru.zavanton.demo.repo.RecipeRepo

@Service
class RecipeServiceImpl(
    private val recipeRepo: RecipeRepo
) : RecipeService {

    override fun fetchRecipes(): Set<Recipe> {
        return recipeRepo.findAll().toSet()
    }
}










### main/kotlin/ru/zavanton/demo/service/RecipeService.kt
package ru.zavanton.demo.service

import ru.zavanton.demo.entity.Recipe

interface RecipeService {

    fun fetchRecipes(): Set<Recipe>
}
