package ru.zavanton.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.util.MultiValueMap
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.controller.dto.PostDTO
import ru.zavanton.demo.data.Post

@RestController
class MyController {

    private val log = LoggerFactory.getLogger(MyController::class.java)

    @GetMapping("/posts")
    fun fetchPostById(
        @RequestHeader(name = "Content-Type", required = false, defaultValue = "default")
        cacheControl: String,
        @RequestHeader(name = "Custom-Header", required = false, defaultValue = "default")
        customHeader: String
    ): PostDTO {
        log.info("zavanton - cache control: $cacheControl")
        log.info("zavanton - custom header: $customHeader")

        val post = Post(0L, "Title", "Content", "zavanton")
        return PostDTO(
            id = post.id,
            title = post.title,
            author = post.author
        )
    }

    @GetMapping("/demo")
    fun demo(
        @RequestHeader headers: MultiValueMap<String, String>
    ): String {
        headers.forEach { (key, value) ->
            log.info("zavanton - key: $key, value: $value")
        }
        return "demo"
    }
}
