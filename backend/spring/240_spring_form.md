# Java Spring - get and post to html form



### resources/data.sql
insert into category (title) values ('category00');
insert into category (title) values ('category10');
insert into category (title) values ('category20');










### resources/application.yml
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











### resources/templates/index.html
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










### resources/templates/recipe/show.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Show Recipe</title>
</head>
<body>
<h1>Show Recipe</h1>
<p th:text="${recipe.id}">info...</p>
<p th:text="${recipe.contents}">info...</p>
<p th:text="${recipe.difficulty}">info...</p>
</body>
</html>










### resources/templates/recipe/recipeform.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Create a New Recipe</title>
</head>
<body>

<h1>Create a New Recipe</h1>

<p th:text="'Creating a new recipe...'">subtitle...</p>

<form th:action="@{/recipe/create}" method="POST">
    <input type="hidden" th:field="${recipe.id}"/>

    <label>Recipe content</label>
    <input type="text" th:field="${recipe.contents}"/>


</form>

</body>
</html>










### kotlin/ru/zavanton/demo/MyDemoApplication.kt
package ru.zavanton.demo

import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class MyDemoApplication

private val log = LoggerFactory.getLogger("main")

fun main(args: Array<String>) {
    val context = runApplication<MyDemoApplication>(*args)
}










### kotlin/ru/zavanton/demo/startup/MyRunner.kt
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
        val unit1 = MeasureUnit()
        unit1.description = "unit1"

        val unit2 = MeasureUnit()
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
        note1.desc = "note1"
        recipe1.addNote(note1)

        recipeRepo.save(recipe1)

        log.info("zavanton - initial data saved...")
    }
}










### kotlin/ru/zavanton/demo/command/NoteCommand.kt
package ru.zavanton.demo.command

class NoteCommand(
    val id: Long = 0,
    val desc: String = ""
)










### kotlin/ru/zavanton/demo/command/MeasureUnitCommand.kt
package ru.zavanton.demo.command

class MeasureUnitCommand(
    val id: Long = 0,
    val description: String = ""
)










### kotlin/ru/zavanton/demo/command/RecipeCommand.kt
package ru.zavanton.demo.command

import ru.zavanton.demo.entity.Difficulty

class RecipeCommand(
    var id: Long = 0,
    var contents: String = "",
    var note: NoteCommand? = null,
    var ingredients: MutableSet<IngredientCommand> = mutableSetOf(),
    var difficulty: Difficulty = Difficulty.NORMAL,
    var categories: MutableSet<CategoryCommand> = mutableSetOf()
)










### kotlin/ru/zavanton/demo/command/CategoryCommand.kt
package ru.zavanton.demo.command

class CategoryCommand(
    var id: Long = 0,
    var title: String = ""
)










### kotlin/ru/zavanton/demo/command/IngredientCommand.kt
package ru.zavanton.demo.command

class IngredientCommand(
    val id: Long = 0,
    val name: String = "",
    val unit: MeasureUnitCommand? = null
)










### kotlin/ru/zavanton/demo/controller/RecipeController.kt
package ru.zavanton.demo.controller

import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.ModelAttribute
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import ru.zavanton.demo.command.RecipeCommand
import ru.zavanton.demo.service.RecipeService

@Controller
class RecipeController(
    private val recipeService: RecipeService
) {

    @GetMapping("/recipes/{id}")
    fun showRecipeById(
        @PathVariable("id") id: Long,
        model: Model
    ): String {
        val recipe = recipeService.fetchById(id)
        model.addAttribute("recipe", recipe)
        return "recipe/show"
    }

    @GetMapping("/recipes/new")
    fun showNewRecipeForm(
        model: Model
    ): String {
        model.addAttribute("recipe", RecipeCommand())
        return "recipe/recipeform"
    }

    @PostMapping("/recipe/create")
    fun processNewRecipeForm(
        @ModelAttribute command: RecipeCommand
    ): String {
        val saveRecipeCommand = recipeService.saveRecipeCommand(command)
        return "redirect:/recipes/${saveRecipeCommand.id}"
    }
}










### kotlin/ru/zavanton/demo/controller/IndexController.kt
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










### kotlin/ru/zavanton/demo/repo/UnitOfMeasureRepo.kt
package ru.zavanton.demo.repo

import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.MeasureUnit

@Repository
interface UnitOfMeasureRepo : CrudRepository<MeasureUnit, Long>{
}










### kotlin/ru/zavanton/demo/repo/RecipeRepo.kt
package ru.zavanton.demo.repo

import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Recipe

@Repository
interface RecipeRepo : CrudRepository<Recipe, Long>{
}










### kotlin/ru/zavanton/demo/repo/NoteRepo.kt
package ru.zavanton.demo.repo

import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Note

@Repository
interface NoteRepo : CrudRepository<Note, Long> {
}










### kotlin/ru/zavanton/demo/repo/IngredientRepo.kt
package ru.zavanton.demo.repo

import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Ingredient

@Repository
interface IngredientRepo : CrudRepository<Ingredient, Long>{
}










### kotlin/ru/zavanton/demo/repo/CategoryRepo.kt
package ru.zavanton.demo.repo

import java.util.*
import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Category

@Repository
interface CategoryRepo : CrudRepository<Category, Long> {

    fun findByTitle(title: String): Optional<Category>
}










### kotlin/ru/zavanton/demo/entity/MeasureUnit.kt
package ru.zavanton.demo.entity

import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
class MeasureUnit(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(name = "unit_desc")
    var description: String = ""
)










### kotlin/ru/zavanton/demo/entity/Note.kt
package ru.zavanton.demo.entity

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.Lob
import javax.persistence.OneToOne

@Entity
class Note(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Lob
    var desc: String = "",

    @OneToOne
    var recipe: Recipe? = null,
) {
    fun addRecipe(recipe: Recipe) {
        this.recipe = recipe
        recipe.note = this
    }
}










### kotlin/ru/zavanton/demo/entity/Ingredient.kt
package ru.zavanton.demo.entity

import javax.persistence.CascadeType
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.FetchType
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.ManyToOne
import javax.persistence.OneToOne

@Entity
class Ingredient(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(name = "ingredient_name")
    var name: String = "",

    @OneToOne(fetch = FetchType.EAGER, cascade = [CascadeType.ALL])
    var unit: MeasureUnit? = null,

    @ManyToOne
    var recipe: Recipe? = null
)










### kotlin/ru/zavanton/demo/entity/Difficulty.kt
package ru.zavanton.demo.entity

enum class Difficulty {
    EASY, NORMAL, HARD
}










### kotlin/ru/zavanton/demo/entity/Recipe.kt
package ru.zavanton.demo.entity

import javax.persistence.CascadeType
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.EnumType
import javax.persistence.Enumerated
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.JoinTable
import javax.persistence.Lob
import javax.persistence.ManyToMany
import javax.persistence.OneToMany
import javax.persistence.OneToOne

@Entity
class Recipe(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Lob
    @Column(name = "recipe_contents")
    var contents: String = "",

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










### kotlin/ru/zavanton/demo/entity/Category.kt
package ru.zavanton.demo.entity

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.ManyToMany

@Entity
class Category(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    var title: String = "",

    @ManyToMany(mappedBy = "categories")
    val recipes: MutableSet<Recipe> = mutableSetOf()
)










### kotlin/ru/zavanton/demo/converter/RecipeEntityToCommandConverter.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component
import ru.zavanton.demo.command.RecipeCommand
import ru.zavanton.demo.entity.Recipe

@Component
class RecipeEntityToCommandConverter(
    private val noteConverter: NoteEntityToCommandConverter,
    private val ingredientConverter: IngredientEntityToCommandConverter
) : Converter<Recipe, RecipeCommand> {

    override fun convert(source: Recipe): RecipeCommand {
        return RecipeCommand(
            id = source.id,
            contents = source.contents,
            note = source.note?.let { noteConverter.convert(it) },
            ingredients = source.ingredients.map {
                ingredientConverter.convert(it)
            }.toMutableSet(),
            difficulty = source.difficulty
        )
    }
}










### kotlin/ru/zavanton/demo/converter/MeasureUnitCommandToEntityConverter.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component
import ru.zavanton.demo.command.MeasureUnitCommand
import ru.zavanton.demo.entity.MeasureUnit

@Component
class MeasureUnitCommandToEntityConverter : Converter<MeasureUnitCommand, MeasureUnit> {

    override fun convert(source: MeasureUnitCommand): MeasureUnit {
        return MeasureUnit(
            id = source.id,
            description = source.description
        )
    }
}










### kotlin/ru/zavanton/demo/converter/IngredientEntityToCommandConverter.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component
import ru.zavanton.demo.command.IngredientCommand
import ru.zavanton.demo.entity.Ingredient

@Component
class IngredientEntityToCommandConverter(
    private val converter: MeasureUnitEntityToCommandConverter
) : Converter<Ingredient, IngredientCommand> {

    override fun convert(source: Ingredient): IngredientCommand {
        return IngredientCommand(
            id = source.id,
            name = source.name,
            unit = source.unit?.let { converter.convert(it) }
        )
    }
}










### kotlin/ru/zavanton/demo/converter/MeasureUnitEntityToCommandConverter.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component
import ru.zavanton.demo.command.MeasureUnitCommand
import ru.zavanton.demo.entity.MeasureUnit

@Component
class MeasureUnitEntityToCommandConverter : Converter<MeasureUnit, MeasureUnitCommand> {

    override fun convert(source: MeasureUnit): MeasureUnitCommand {
        return MeasureUnitCommand(
            id = source.id,
            description = source.description
        )
    }
}










### kotlin/ru/zavanton/demo/converter/NoteCommandToEntityConverter.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component
import ru.zavanton.demo.command.NoteCommand
import ru.zavanton.demo.entity.Note

@Component
class NoteCommandToEntityConverter : Converter<NoteCommand, Note> {

    override fun convert(source: NoteCommand): Note {
        return Note(
            id = source.id,
            desc = source.desc
        )
    }
}










### kotlin/ru/zavanton/demo/converter/CategoryEntityToCommandConverter.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component
import ru.zavanton.demo.command.CategoryCommand
import ru.zavanton.demo.entity.Category

@Component
class CategoryEntityToCommandConverter : Converter<Category, CategoryCommand> {

    override fun convert(source: Category): CategoryCommand {
        return CategoryCommand(
            id = source.id,
            title = source.title
        )
    }
}










### kotlin/ru/zavanton/demo/converter/IngredientCommandToEntityConverter.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component
import ru.zavanton.demo.command.IngredientCommand
import ru.zavanton.demo.entity.Ingredient

@Component
class IngredientCommandToEntityConverter(
    private val converter: MeasureUnitCommandToEntityConverter
) : Converter<IngredientCommand, Ingredient> {

    override fun convert(source: IngredientCommand): Ingredient {
        return Ingredient(
            id = source.id,
            name = source.name,
            unit = source.unit?.let { converter.convert(it) }
        )
    }
}










### kotlin/ru/zavanton/demo/converter/RecipeCommandToEntityConverter.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component
import ru.zavanton.demo.command.RecipeCommand
import ru.zavanton.demo.entity.Recipe

@Component
class RecipeCommandToEntityConverter(
    private val noteConverter: NoteCommandToEntityConverter,
    private val ingredientConverter: IngredientCommandToEntityConverter
) : Converter<RecipeCommand, Recipe> {

    override fun convert(source: RecipeCommand): Recipe {
        return Recipe(
            id = source.id,
            contents = source.contents,
            note = source.note?.let { noteConverter.convert(it) },
            ingredients = source.ingredients.map {
                ingredientConverter.convert(it)
            }.toMutableSet()
        )
    }
}










### kotlin/ru/zavanton/demo/converter/NoteEntityToCommandConverter.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component
import ru.zavanton.demo.command.NoteCommand
import ru.zavanton.demo.entity.Note

@Component
class NoteEntityToCommandConverter : Converter<Note, NoteCommand> {

    override fun convert(source: Note): NoteCommand {
        return NoteCommand(
            id = source.id,
            desc = source.desc
        )
    }
}










### kotlin/ru/zavanton/demo/converter/CategoryCommandToEntityConverter.kt
package ru.zavanton.demo.converter

import org.springframework.core.convert.converter.Converter
import org.springframework.stereotype.Component
import ru.zavanton.demo.command.CategoryCommand
import ru.zavanton.demo.entity.Category

@Component
class CategoryCommandToEntityConverter : Converter<CategoryCommand, Category> {

    override fun convert(source: CategoryCommand): Category {
        return Category(
            id = source.id,
            title = source.title
        )
    }
}










### kotlin/ru/zavanton/demo/service/RecipeServiceImpl.kt
package ru.zavanton.demo.service

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import ru.zavanton.demo.command.RecipeCommand
import ru.zavanton.demo.converter.RecipeCommandToEntityConverter
import ru.zavanton.demo.converter.RecipeEntityToCommandConverter
import ru.zavanton.demo.entity.Recipe
import ru.zavanton.demo.repo.RecipeRepo

@Service
class RecipeServiceImpl(
    private val recipeRepo: RecipeRepo,
    private val converter: RecipeCommandToEntityConverter,
    private val inverseConverter: RecipeEntityToCommandConverter
) : RecipeService {

    override fun fetchRecipes(): Set<Recipe> {
        return recipeRepo.findAll().toSet()
    }

    override fun fetchById(id: Long): Recipe {
        val optional = recipeRepo.findById(id)
        return if (optional.isPresent) {
            optional.get()
        } else {
            throw RuntimeException("Recipe with id $id does not exist")
        }
    }

    @Transactional
    override fun saveRecipeCommand(command: RecipeCommand): RecipeCommand {
        val recipe = converter.convert(command)
        val savedRecipe = recipeRepo.save(recipe)
        return inverseConverter.convert(savedRecipe)
    }
}










### kotlin/ru/zavanton/demo/service/RecipeService.kt
package ru.zavanton.demo.service

import ru.zavanton.demo.command.RecipeCommand
import ru.zavanton.demo.entity.Recipe

interface RecipeService {

    fun fetchRecipes(): Set<Recipe>

    fun fetchById(id: Long): Recipe

    fun saveRecipeCommand(command: RecipeCommand): RecipeCommand
}
