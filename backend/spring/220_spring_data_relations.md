# Java Spring - Save data to db (one to one, one to many and many to many relationships) (@Id, @GeneratedValue, @OneToOne, @OneToMany, @ManyToMany, @Lob, @Enumerated, @JoinTable, JoinColumn)

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
    defer-datasource-initialization: true
    database-platform: org.hibernate.dialect.H2Dialect
    
    
    
    
### resources/data.sql
insert into category (id, title) values (0, 'category00');
insert into category (id, title) values (1, 'category10');
insert into category (id, title) values (2, 'category20');











### kotlin/ru/zavanton/demo/MyDemoApplication.kt
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
        val unit1 = UnitOfMeasure()
        unit1.description = "unit1"

        val unit2 = UnitOfMeasure()
        unit2.description = "unit2"

        val ingredient1 = Ingredient()
        ingredient1.unit = unit1
        ingredient1.name = "ingredient1"

        val recipe1 = Recipe()
        recipe1.difficulty = Difficulty.HARD
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










### kotlin/ru/zavanton/demo/repo/UnitOfMeasureRepo.kt
package ru.zavanton.demo.repo

import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.UnitOfMeasure

@Repository
interface UnitOfMeasureRepo : CrudRepository<UnitOfMeasure, Long>{
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

import org.springframework.data.repository.CrudRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Category

@Repository
interface CategoryRepo : CrudRepository<Category, Long>{
}










### kotlin/ru/zavanton/demo/entity/UnitOfMeasure.kt
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










### kotlin/ru/zavanton/demo/entity/Note.kt
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










### kotlin/ru/zavanton/demo/entity/Ingredient.kt
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









### kotlin/ru/zavanton/demo/entity/Difficulty.kt
package ru.zavanton.demo.entity

enum class Difficulty {
    EASY, NORMAL, HARD
}










### kotlin/ru/zavanton/demo/entity/Recipe.kt
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










### kotlin/ru/zavanton/demo/entity/Category.kt
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
