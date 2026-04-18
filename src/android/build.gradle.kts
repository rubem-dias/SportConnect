import java.util.Properties

// Lê o token secreto do Mapbox de android/secrets.properties (gitignored).
// Fallback: variável de ambiente MAPBOX_DOWNLOADS_TOKEN (útil em CI/CD).
val secretsFile = rootProject.file("secrets.properties")
val mapboxDownloadsToken: String = if (secretsFile.exists()) {
    Properties().apply { secretsFile.inputStream().use { load(it) } }
        .getProperty("MAPBOX_DOWNLOADS_TOKEN", "")
} else {
    System.getenv("MAPBOX_DOWNLOADS_TOKEN") ?: ""
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // Repositório privado do Mapbox SDK para Android.
        // Token lido de android/secrets.properties — nunca commitar esse arquivo.
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            authentication {
                create<BasicAuthentication>("basic")
            }
            credentials {
                username = "mapbox"
                password = mapboxDownloadsToken
            }
        }
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
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
