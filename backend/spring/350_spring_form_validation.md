# Spring - Form Validation (show and customize validation errors)





### resources/ValidationMessages.properties
title.not_empty=The title must not be empty
title.correct_length=The title must be between 2 and 5 letters










### resources/application.yml
server:
  port: 8989


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










### resources/static/styles.css
.validation-error {
    color: red;
}










### resources/templates/create_game.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Create a New Game</title>
    <link type="text/css" rel="stylesheet" th:href="@{/styles.css}"/>
</head>
<body>
<h1>Create a New Game</h1>


<form th:object="${game}" th:action="@{/games/process_create}" method="post">
    <input type="hidden" th:field="*{id}"/>

    <label>Name:</label>
    <br/>

    <input type="text" th:field="*{title}" id="title"/>
    <br/>

    <!-- this is validation error output -->
    <ul th:each="error : ${#fields.errors('title')}">
        <li th:text="${error}" class="validation-error"></li>
    </ul>

    <input type="submit" value="Create"/>
</form>

</body>
</html>









### resources/templates/index.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Home</title>
</head>
<body>
<h1>Home</h1>
<a th:href="@{/games/create}">Create a new game</a>
</body>
</html>










### kotlin/ru/zavanton/forms/App.kt
package ru.zavanton.forms

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class FormsPracticeApplication

fun main(args: Array<String>) {
	runApplication<FormsPracticeApplication>(*args)
}










### kotlin/ru/zavanton/forms/repository/GameRepository.kt
package ru.zavanton.forms.repository

import java.util.Optional
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.forms.data.Game

@Repository
interface GameRepository : JpaRepository<Game, Long> {

    fun findByTitle(title: String): Optional<Game>
}










### kotlin/ru/zavanton/forms/data/Game.kt
package ru.zavanton.forms.data

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import ru.zavanton.forms.utils.EMPTY

@Entity
data class Game(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,

    var title: String = EMPTY,
)










### kotlin/ru/zavanton/forms/controller/GameController.kt
package ru.zavanton.forms.controller

import javax.validation.Valid
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.validation.Errors
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.ModelAttribute
import org.springframework.web.bind.annotation.PostMapping
import ru.zavanton.forms.service.GameService
import ru.zavanton.forms.service.dto.GameDTO

@Controller
class GameController(
    private val gameService: GameService
) {

    private val log = LoggerFactory.getLogger(GameController::class.java)

    @GetMapping("")
    fun index(): String {
        return "index"
    }

    @GetMapping("/games/create")
    fun createGame(
        model: Model
    ): String {
        val gameDTO = GameDTO()
        model.addAttribute("game", gameDTO)
        return "create_game"
    }

    @PostMapping("/games/process_create")
    fun processCreateGame(
        @Valid @ModelAttribute("game") game: GameDTO,
        errors: Errors
    ): String {
        log.info("zavanton - has errors: ${errors.hasErrors()}")

        if (errors.hasErrors()) {
            return "create_game"
        }
        gameService.saveGameDTO(game)
        return "redirect:/"
    }
}























### kotlin/ru/zavanton/forms/utils/utils.kt
package ru.zavanton.forms.utils

const val EMPTY = ""










### kotlin/ru/zavanton/forms/service/GameService.kt
package ru.zavanton.forms.service

import ru.zavanton.forms.service.dto.GameDTO

interface GameService {

    fun saveGameDTO(gameDTO: GameDTO): GameDTO
}









### kotlin/ru/zavanton/forms/service/GameServiceImpl.kt
package ru.zavanton.forms.service

import org.springframework.stereotype.Service
import ru.zavanton.forms.repository.GameRepository
import ru.zavanton.forms.service.dto.GameDTO
import ru.zavanton.forms.service.mapper.GameMapper

@Service
class GameServiceImpl(
    private val gameRepository: GameRepository,
    private val gameMapper: GameMapper,
) : GameService {

    override fun saveGameDTO(gameDTO: GameDTO): GameDTO {
        val game = gameMapper.mapToEntity(gameDTO)
        val savedGame = gameRepository.save(game)
        return gameMapper.mapToDTO(savedGame)
    }
}










### kotlin/ru/zavanton/forms/service/mapper/GameMapperImpl.kt
package ru.zavanton.forms.service.mapper

import org.springframework.stereotype.Component
import ru.zavanton.forms.data.Game
import ru.zavanton.forms.service.dto.GameDTO

@Component
class GameMapperImpl : GameMapper {

    override fun mapToEntity(gameDTO: GameDTO): Game {
        return Game(
            id = gameDTO.id,
            title = gameDTO.title
        )
    }

    override fun mapToDTO(game: Game): GameDTO {
        return GameDTO(
            id = game.id,
            title = game.title
        )
    }
}










### kotlin/ru/zavanton/forms/service/mapper/GameMapper.kt
package ru.zavanton.forms.service.mapper

import ru.zavanton.forms.data.Game
import ru.zavanton.forms.service.dto.GameDTO

interface GameMapper {

    fun mapToEntity(gameDTO: GameDTO): Game

    fun mapToDTO(game: Game): GameDTO
}










### kotlin/ru/zavanton/forms/service/dto/GameDTO.kt
package ru.zavanton.forms.service.dto

import javax.validation.constraints.NotEmpty
import javax.validation.constraints.Size
import ru.zavanton.forms.utils.EMPTY

data class GameDTO(
    var id: Long = 0L,

    // Note: 'field' or 'get' target is needed
    // otherwise validation will not be working
    @get:NotEmpty(message = "{title.not_empty}")
    @get:Size(min = 2, max = 5, message = "{title.correct_length}")
    var title: String = EMPTY
)
