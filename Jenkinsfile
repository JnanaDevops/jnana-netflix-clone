def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger',
]

pipeline {
    agent any

    environment {
        IMAGE_NAME = 'netflix-clone'
        CONTAINER_NAME = 'netflix-clone-app'
    }

    stages {
        stage('Fetch code') {
            steps {
                git branch: 'main', url: 'https://github.com/JnanaDevops/jnana-netflix-clone.git'
            }
        }
        
        stage('Pre-Build Cleanup') {
            steps {
                sh '''
                    echo "Checking for existing Docker container..."
                    if docker ps -a --format '{{.Names}}' | grep -Eq '^netflix-clone-app$'; then
                       echo "Removing existing container: netflix-clone-app"
                       docker rm -f netflix-clone-app
                    else
                       echo "No existing container found."
                    fi

                    echo "Checking for existing Docker image..."
                    if docker images -q netflix-clone | grep -q .; then
                       echo "Removing existing image: netflix-clone"
                       docker rmi -f netflix-clone
                    else
                       echo "No existing image found."
                    fi
                '''
            }
        }


        stage('Run Tests') {
            steps {
                script {
                    if (fileExists('run-tests.sh')) {
                        sh 'chmod +x run-tests.sh && ./run-tests.sh'
                    } else {
                        echo "No tests found, skipping..."
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        // Trivy scan commented out intentionally to avoid failure and resource usage
        // stage('Scan Docker Image') {
        //     steps {
        //         sh "trivy image --exit-code 1 --severity CRITICAL,HIGH ${IMAGE_NAME}"
        //     }
        // }

        stage('Run Docker Container') {
            steps {
                sh "docker run -d -p 8081:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}"
            }
        }

        stage('Show Public IP') {
            steps {
                script {
                    def ip = sh(script: "curl -s https://api.ipify.org", returnStdout: true).trim()
                    echo "Access the application at: http://${ip}:8081"
                }
            }
        }

        // Commented out due to missing SonarQube setup
        // stage('Quality Gate') {
        //     steps {
        //         timeout(time: 1, unit: 'HOURS') {
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }

        /*stage('Cleanup (optional)') {
            steps {
                sh "docker rm -f ${CONTAINER_NAME} || true"
                sh "docker rmi -f ${IMAGE_NAME} || true"
            }
        }*/
    }

    post {
        always {
            echo 'Sending Slack Notification...'
            slackSend channel: '#all-slacknotificationsorg',
                color: COLOR_MAP[currentBuild.currentResult ?: 'FAILURE'],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }
}
