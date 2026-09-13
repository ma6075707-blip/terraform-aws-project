
pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['APPLY', 'DESTROY'],
            description: 'Choose Terraform action'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'eu-west-1'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform']
                ]) {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Format') {
            steps {
                sh 'terraform fmt -check -recursive'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            when {
                expression {
                    params.ACTION == 'APPLY'
                }
            }
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform']
                ]) {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Approval - Apply') {
            when {
                expression {
                    params.ACTION == 'APPLY'
                }
            }
            steps {
                input message: 'Apply Terraform infrastructure?',
                      ok: 'Apply'
            }
        }

        stage('Terraform Apply') {
            when {
                expression {
                    params.ACTION == 'APPLY'
                }
            }
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform']
                ]) {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Approval - Destroy') {
            when {
                expression {
                    params.ACTION == 'DESTROY'
                }
            }
            steps {
                input message: 'WARNING: Destroy Terraform infrastructure?',
                      ok: 'Destroy'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression {
                    params.ACTION == 'DESTROY'
                }
            }
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-terraform']
                ]) {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }

    post {
        success {
            echo "Terraform ${params.ACTION} completed successfully!"
        }

        failure {
            echo "Terraform ${params.ACTION} failed!"
        }
    }
}

