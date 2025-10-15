pipeline {
    agent any

    tools {
        maven 'Maven-3.8.7'
    }

    environment {
        SONARQUBE_ENV = 'SonarQube-Local'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${env.SONARQUBE_ENV}") {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
                            mvn sonar:sonar \
                            -Dsonar.projectKey=HCL-POC \
                            -Dsonar.projectName=HCL-POC \
                            -Dsonar.host.url=http://3.106.149.220:9000 \
                            -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage('Trivy Scan - Project Directory') {
            steps {
                sh '''
                    echo "Running Trivy scan on project directory.."
                    trivy fs . --scanners vuln --exit-code 0 --severity HIGH,CRITICAL --format table
                '''
            }
        }

        stage('Trivy Scan - JAR File') {
            steps {
                sh '''
                    echo "Extracting JAR for Trivy scan..."
                    mkdir -p jar-extracted
                    unzip -o target/hello-world-1.0-SNAPSHOT.jar -d jar-extracted
                    echo "Running Trivy scan on extracted JAR."
                    trivy fs jar-extracted --scanners vuln --exit-code 0 --severity HIGH,CRITICAL --format table
                '''
            }
        }

        stage('Deploy to Nexus') {
            steps {
                sh '''
                    mvn deploy -s settings.xml -DskipTests=true \
                    -DaltDeploymentRepository=maven-releases::http://3.106.149.220:8081/repository/maven-releases/
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Build, analysis, scans, and deployment completed successfully.'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}
