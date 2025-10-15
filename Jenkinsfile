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
        stage('Prepare Maven Settings') {
            steps {
                sh 'cp setting.xml $WORKSPACE/settings.xml'
            } 
        }

        stage('Deploy to Nexus') {
            steps {
                sh '''
                    mvn deploy -s settings.xml -DskipTests=true \
                    -DaltDeploymentRepository=maven-snapshots::http://3.106.149.220:8081/repository/maven-snapshots/
                '''
            }
        }

        stage('Download JAR from Nexus') {
            steps {
               sh '''
                    echo "Fetching JAR from Nexus..."
                    curl -u admin:Salary@2025 -O http://3.106.149.220:8081/repository/maven-snapshots/com/example/hello-world/1.0-SNAPSHOT/hello-world-1.0-SNAPSHOT.jar
               '''
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                        docker build -t sandysame/hello-world:1.0-SNAPSHOT .
                        docker push sandysame/hello-world:1.0-SNAPSHOT
                    '''
               }
            }
        }
        stage('Trivy Scan - Docker Image') {
             steps {
                 sh '''
                   echo "Running Trivy scan on Docker image..."
                   trivy image --exit-code 0 --severity HIGH,CRITICAL --format table sandysame/hello-world:1.0-SNAPSHOT
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
