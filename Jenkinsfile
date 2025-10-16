        stage('Trivy Scan - Docker Image') {
            steps {
                sh '''
                   echo "Running Trivy scan on Docker image..."
                   trivy image --exit-code 0 --severity HIGH,CRITICAL --format table sandysame/hello-world:1.0-SNAPSHOT
                '''
            }
        }

        stage('Helm Deploy to EKS') {
            steps {
                withCredentials([string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                                 string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                       export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                       export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                       aws eks update-kubeconfig --region ap-southeast-2 --name hello-world-cluster

                       helm upgrade --install hello-world-release ./hello-world-chart \
                       --set image.tag=${BUILD_NUMBER}
                    '''
                }
            }
        }
    } // closes stages

    post {
        success {
            echo '✅ Build, analysis, scans, and deployment completed successfully.'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
} // closes pipeline
