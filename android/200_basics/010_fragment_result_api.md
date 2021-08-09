# Fragment Result Api

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
    dataBinding {
        enabled true
    }
}

dependencies {

    implementation group: 'androidx.fragment', name: 'fragment-ktx', version: '1.3.6'
    implementation "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
    implementation 'androidx.core:core-ktx:1.6.0'
    implementation 'androidx.appcompat:appcompat:1.3.1'
    implementation 'com.google.android.material:material:1.4.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.0'
    testImplementation 'junit:junit:4.+'
    androidTestImplementation 'androidx.test.ext:junit:1.1.3'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.4.0'
}




### MainActivity.kt
package com.example.demoresultapi

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.databinding.DataBindingUtil
import com.example.demoresultapi.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val binding = DataBindingUtil.setContentView<ActivityMainBinding>(this, R.layout.activity_main)

        if (supportFragmentManager.findFragmentById(R.id.fragmentContainerA) == null) {
            supportFragmentManager.beginTransaction()
                .add(R.id.fragmentContainerA, FragmentA())
                .commit()
        }

        if (supportFragmentManager.findFragmentById(R.id.fragmentContainerB) == null) {
            supportFragmentManager.beginTransaction()
                .add(R.id.fragmentContainerB, FragmentB())
                .commit()
        }
    }
}




### FragmentA.kt
package com.example.demoresultapi

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.fragment.app.setFragmentResultListener
import com.example.demoresultapi.databinding.FragmentABinding

class FragmentA : Fragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val binding = DataBindingUtil.inflate<FragmentABinding>(inflater, R.layout.fragment_a, container, false)

        setFragmentResultListener(FragmentB.GENERATE_NUMBER_KEY) { requestKey, bundle ->
            Log.d("zavanton", "zavanton - requestKey: $requestKey")
            val randomNumber = bundle.getString(FragmentB.NUMBER_KEY)
            binding.tvNumber.text = randomNumber
        }

        return binding.root
    }
}




### FragmentB.kt
package com.example.demoresultapi

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.fragment.app.setFragmentResult
import com.example.demoresultapi.databinding.FragmentBBinding

class FragmentB : Fragment() {

    companion object {
        const val GENERATE_NUMBER_KEY = "GENERATE_NUMBER_KEY"
        const val NUMBER_KEY = "NUMBER_KEY"
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val binding = DataBindingUtil.inflate<FragmentBBinding>(inflater, R.layout.fragment_b, container, false)
        binding.tvGenerate.text = "Generate"

        binding.tvGenerate.setOnClickListener {
            val randomNumber = (Math.random() * 100).toString()
            val bundle = Bundle()
            bundle.putString(NUMBER_KEY, randomNumber)

            setFragmentResult(GENERATE_NUMBER_KEY, bundle)
        }

        return binding.root
    }
}



### activity_main.xml
```
<?xml version="1.0" encoding="utf-8"?>
<layout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    >

    <data>

    </data>

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical"
        android:weightSum="100"
        tools:context=".MainActivity"
        >

        <FrameLayout
            android:id="@+id/fragmentContainerA"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:layout_weight="50"
            android:background="#00ff00"
            />

        <FrameLayout
            android:id="@+id/fragmentContainerB"
            android:layout_width="match_parent"
            android:layout_height="match_parent"
            android:layout_weight="50"
            android:background="#0000ff"
            />
    </LinearLayout>
</layout>
```
