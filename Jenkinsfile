pipeline {
  agent {
    docker {
      // Linux container with Maven and Java already installed
      image 'maven:3.9-eclipse-temurin-17'

      // Reuse Maven dependency cache between builds (faster)
      args '-v maven_repo:/root/.m2'
    }
  }

  options {
    timestamps()
    timeout(time: 30, unit: 'MINUTES')
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  environment {
    //injected through jenkins credentials manager
    GOREST_TOKEN = credentials('gorest-token')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Tooling Info') {
      steps {
        sh '''
          echo "=== JAVA ==="
          java -version
          echo "=== MAVEN ==="
          mvn -version
        '''
      }
    }

    stage('Run Karate Tests') {
      steps {
        sh '''
          mvn clean test \
            -Dgorest.token=$GOREST_TOKEN
        '''
      }
    }
  }

  post {
    always {
      // Jenkins native test reporting
      junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'

      // Keep the raw Karate HTML report folder as build artifacts
      archiveArtifacts allowEmptyArchive: true, artifacts: 'target/karate-reports/**', fingerprint: true

      // Clickable HTML report link in Jenkins UI
      publishHTML(target: [
        reportDir: 'target/karate-reports',
        reportFiles: 'karate-summary.html',
        reportName: 'Karate API Test Report',
        keepAll: true,
        alwaysLinkToLastBuild: true,
        allowMissing: false
      ])
    }

    failure {
      echo 'Build failed. Check "Test Results" and the published Karate HTML report.'
    }
  }
}
