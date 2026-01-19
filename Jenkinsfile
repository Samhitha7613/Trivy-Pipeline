pipeline {
    agent any

    environment {
        IMAGE_NAME = "sample-app"
        IMAGE_TAG = "latest"
    }

    stages {

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Trivy Vulnerability Scan') {
            steps {
                script {
                    echo "Running Trivy Scan..."

                    sh """
                    /opt/homebrew/bin/trivy image --severity CRITICAL,HIGH \
                    --exit-code 0 \
                    --no-progress \
                    --format table \
                    ${IMAGE_NAME}:${IMAGE_TAG} > trivy-report.txt
                    """

                    def vulnCount = sh(
                        script: "/opt/homebrew/bin/trivy image --severity CRITICAL,HIGH --exit-code 0 --no-progress ${IMAGE_NAME}:${IMAGE_TAG} | grep -E 'CRITICAL|HIGH' | wc -l",
                        returnStdout: true
                    ).trim().toInteger()

                    echo "Total High + Critical Vulnerabilities: ${vulnCount}"

                    if (vulnCount > 5) {
                        error "Build failed: Too many High/Critical vulnerabilities (${vulnCount})"
                    }
                }
            }
        }

        stage('Test') {
            steps {
                sh "echo 'Tests passed'"
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'trivy-report.txt'
        }
        success {
            echo "Pipeline Passed"
        }
        failure {
            echo "Pipeline Failed due to vulnerabilities"
        }
    }
}
