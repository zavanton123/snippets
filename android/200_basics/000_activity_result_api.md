# Activity Result API

### MainActivity.kt
package com.example.demoresultapi

import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.example.demoresultapi.contract.MyDetailActivityContract
import com.example.demoresultapi.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private val activityResultLauncher = registerForActivityResult(
        MyDetailActivityContract()
    ) { result -> Log.d("zavanton", "zavanton - name length: $result") }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val binding = DataBindingUtil.setContentView<ActivityMainBinding>(this, R.layout.activity_main)

        binding.tvMain.setOnClickListener {
            activityResultLauncher.launch("Anton Zaviyalov")
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
    }
}



### MyDetailActivityContract.kt
package com.example.demoresultapi.contract

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.activity.result.contract.ActivityResultContract
import com.example.demoresultapi.DetailActivity
import com.example.demoresultapi.DetailActivity.Companion.NAME_EXTRA
import com.example.demoresultapi.DetailActivity.Companion.NAME_LENGTH_EXTRA

class MyDetailActivityContract : ActivityResultContract<String, Int?>() {

    override fun createIntent(context: Context, input: String?): Intent {
        val intent = Intent(context, DetailActivity::class.java)
        intent.putExtra(NAME_EXTRA, input)
        return intent
    }

    override fun parseResult(resultCode: Int, intent: Intent?): Int? {
        return when {
            resultCode != Activity.RESULT_OK -> null
            else -> intent?.getIntExtra(NAME_LENGTH_EXTRA, 0)
        }
    }
}




### build.gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'kotlin-kapt'
}

android {
    compileSdkVersion 30
    buildToolsVersion "30.0.3"

    defaultConfig {
        applicationId "com.example.demoresultapi"
        minSdkVersion 23
        targetSdkVersion 30
        versionCode 1
        versionName "1.0"

        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = '1.8'
    }

    dataBinding.enabled = true
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
    implementation 'androidx.core:core-ktx:1.6.0'
    implementation 'androidx.appcompat:appcompat:1.3.1'
    implementation 'com.google.android.material:material:1.4.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.0'
    testImplementation 'junit:junit:4.+'
    androidTestImplementation 'androidx.test.ext:junit:1.1.3'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.4.0'
}
