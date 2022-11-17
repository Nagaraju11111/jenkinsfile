pipeline {
    agent any
    stages{
        stage('git') {
            steps {
                git branch: 'master', 
                url: 'https://github.com/openmrs/openmrs-core.git'
            }
        }
        stage('build')  {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('test results') {
            steps {
               junit '**/surefire-reports/*.xml'

        }
            }
        stage('archive artifacts') {
            steps {
                archiveArtifacts '**/target/*.jar'

                 }
        }   
            }
    }