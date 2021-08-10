# Activity Result API with ActivityResultContracts

### MainActivity.kt
package com.example.demoresultapi

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.result.ActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.example.demoresultapi.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private val activityResultLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { activityResult: ActivityResult ->
        if (activityResult.resultCode == Activity.RESULT_OK) {
            val nameLength = activityResult.data?.getIntExtra(DetailActivity.NAME_LENGTH_EXTRA, 0)
            Log.d("zavanton", "zavanton - name length: $nameLength")
        } else {
            Log.d("zavanton", "zavanton - cancelled")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val binding = DataBindingUtil.setContentView<ActivityMainBinding>(this, R.layout.activity_main)

        binding.tvMain.setOnClickListener {
            val intent = Intent(this, DetailActivity::class.java)
            intent.putExtra(DetailActivity.NAME_EXTRA, "Anton Zaviyalov")
            activityResultLauncher.launch(intent)
        }
    }
}




### DetailActivity.kt
package com.example.demoresultapi

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.example.demoresultapi.databinding.ActivityDetailBinding

class DetailActivity : AppCompatActivity() {

    companion object {
        const val NAME_EXTRA = "name_extra"
        const val NAME_LENGTH_EXTRA = "name_length_extra"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val name = intent.getStringExtra(NAME_EXTRA) ?: ""

        val binding = DataBindingUtil.setContentView<ActivityDetailBinding>(this, R.layout.activity_detail)
        binding.tvDetail.setOnClickListener {
            Log.d("zavanton", "zavanton - detail click")

            val nameLength = name.length
            val resultIntent = Intent()
            resultIntent.putExtra(NAME_LENGTH_EXTRA, nameLength)
            setResult(Activity.RESULT_OK, resultIntent)
            finish()
        }

        binding.tvDetail.setOnLongClickListener {
            setResult(Activity.RESULT_CANCELED)
            finish()
            true
        }
    }
}
