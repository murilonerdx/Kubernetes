pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        GITHUB_CREDENTIALS_ID = 'github-personal-access-token'
        KUBECONFIG_CREDENTIALS_ID = 'kubeconfig'
        REPO_URL = 'https://github.com/usuario/my-project.git'
    }

    parameters {
        choice(name: 'SERVICE', choices: ['node-service', 'spring-service', 'angular-service'], description: 'Escolha o serviço para construir e implantar')
    }

    stages {
        stage('Checkout') {
            steps {
                git url: env.REPO_URL, credentialsId: env.GITHUB_CREDENTIALS_ID
            }
        }
        stage('Build') {
            steps {
                script {
                    def service = params.SERVICE
                    def dockerImage = "usuario/${service}:latest"

                    dir(service) {
                        sh "docker build -t ${dockerImage} ."
                    }

                    // Save dockerImage to environment variable for use in deploy stage
                    env.DOCKER_IMAGE = dockerImage
                }
            }
        }
        stage('Publish') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        sh "docker push ${env.DOCKER_IMAGE}"
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    withKubeConfig([credentialsId: env.KUBECONFIG_CREDENTIALS_ID]) {
                        sh """
                        kubectl apply -f kubernetes/configmap.yaml
                        kubectl apply -f kubernetes/secret.yaml
                        kubectl apply -f kubernetes/prometheus-config.yaml
                        kubectl apply -f kubernetes/issuer.yaml
                        kubectl apply -f kubernetes/service.yaml

                        kubectl apply -f - <<EOF
                        apiVersion: apps/v1
                        kind: Deployment
                        metadata:
                          name: ${params.SERVICE}
                        spec:
                          replicas: 3
                          selector:
                            matchLabels:
                              app: ${params.SERVICE}
                          template:
                            metadata:
                              labels:
                                app: ${params.SERVICE}
                            spec:
                              containers:
                              - name: ${params.SERVICE}
                                image: ${env.DOCKER_IMAGE}
                                ports:
                                - containerPort: 80
                        EOF
                        """

                        sh "kubectl apply -f kubernetes/hpa.yaml"
                        sh "kubectl apply -f kubernetes/ingress-tls.yaml"
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
