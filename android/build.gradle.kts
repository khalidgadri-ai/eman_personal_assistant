allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// usage_stats 1.3.1 يبني بـ compileSdk 30، فيفشل assembleRelease (أي `flutter run --release` و
// `flutter build apk`) بخطأ "resource android:attr/lStar not found". نرفع أي مكتبة أقدم من 31.
// بناء الـ bundle لا يمرّ بهذه الخطوة فلم يظهر الخطأ هناك.
subprojects {
    val raiseOldCompileSdk: Project.() -> Unit = {
        extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.let { library ->
            val current = library.compileSdk
            if (current != null && current < 31) library.compileSdk = 36
        }
    }
    if (state.executed) raiseOldCompileSdk() else afterEvaluate { raiseOldCompileSdk() }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
