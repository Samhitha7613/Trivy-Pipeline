pipeline {
    agent any

    environment {
        IMAGE_NAME = "sample-app"
        IMAGE_TAG = "latest"
        TRIVY_EXIT_CODE = "0"
    }

    stages {

        stage('Checkout') {
            steps {
                git url: 'https://github.com/your-repo/sample-app.git', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Trivy Vulnerability Scan') {
            steps {
                script {
                    echo "Running Trivy Scan..."

                    // Run Trivy and fail build if CRITICAL or HIGH exceed threshold
                    sh """
                    trivy image --severity CRITICAL,HIGH \
                    --exit-code 0 \
                    --no-progress \
                    --format table \
                    ${IMAGE_NAME}:${IMAGE_TAG} > trivy-report.txt
                    """

                    // Check number of HIGH + CRITICAL vulnerabilities
                    def vulnCount = sh(
                        script: "trivy image --severity CRITICAL,HIGH --exit-code 0 --no-progress ${IMAGE_NAME}:${IMAGE_TAG} | grep -E 'CRITICAL|HIGH' | wc -l",
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
                echo "Running tests..."
                sh "echo 'No tests configured - demo stage'"
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'trivy-report.txt'
        }
        failure {
            echo "Pipeline failed due to security vulnerabilities."
        }
        success {
            echo "Pipeline passed successfully!"
        }
    }
}

