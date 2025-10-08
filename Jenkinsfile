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
                            -Dsonar.host.url=http://52.63.18.94:9000 \
                            -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage('Trivy Scan - Project Directory') {
            steps {
                sh '''
                    echo "Running Trivy scan on project directory..."
                    trivy fs . --exit-code 0 --severity HIGH,CRITICAL --format table
                '''
            }
        }

        stage('Trivy Scan - JAR File') {
            steps {
                sh '''
                    echo "Running Trivy scan on packaged JAR.."
                    trivy fs target/hello-world-1.0-SNAPSHOT.jar --exit-code 0 --severity HIGH,CRITICAL --format table
                '''
            }
        }
    }

    post {
        success {
            echo 'Build, analysis, and vulnerability scans completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
