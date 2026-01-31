pipeline {
  agent {
    docker {
      // Linux container with Maven and Java already installed
      image 'maven:3.9-eclipse-temurin-17'

      // Run container as root (required for apt-get) and reuse Maven cache via mounted volume
      args '--user root -v maven_repo:/root/.m2'
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
    TESTRAIL_USER = credentials('testrail-user')
    TESTRAIL_KEY  = credentials('testrail-api-key')

    TESTRAIL_URL     = 'https://vamsiv06.testrail.io'
    TESTRAIL_PROJECT = 'API AUTOMATION(GO REST)'
    TESTRAIL_SUITE   = 6

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

    stage('Install Python and venv for TRCLI') {
      steps {
        sh '''
          apt-get update
          apt-get install -y --no-install-recommends python3 python3-venv ca-certificates
          python3 --version
        '''
      }
    }

    stage('Publish Results to TestRail') {
      steps {
        sh '''
        # Create isolated python environment so pip installs are allowed (PEP 668 safe)
        python3 -m venv .venv

        # Use venv python/pip
          . .venv/bin/activate

        # Upgrade pip inside venv and install TRCLI
          pip install --upgrade pip
          pip install --upgrade trcli

          trcli -y parse_junit \
                --host "$TESTRAIL_URL" \
                --username "$TESTRAIL_USER" \
                --password "$TESTRAIL_KEY" \
                --project "$TESTRAIL_PROJECT" \
                --suite-id "$TESTRAIL_SUITE" \
                --title "Karate API Run - ${JOB_NAME} #${BUILD_NUMBER}" \
                --close-run \
                -f target/surefire-reports/*.xml

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
