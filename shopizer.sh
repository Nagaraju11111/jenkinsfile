pipeline {
    agent any
    stages {
        stage('git') {
            steps {
                git url: 'https://github.com/shopizer-ecommerce/shopizer.git',
                    branch: 'master'
            }
        }
        stage('maven') {
            steps {
                sh script: 'mvn clean install'
            }
        }
        stage('Archive artifacts') {
            steps {
                archive includes: '**/target/*.jar'
            }
        }
        stage('Archive JUnit-formatted test results') {
            steps {
                junit testResults: '**/target/surefire-reports/*.xml'
            }
        }
    }
}