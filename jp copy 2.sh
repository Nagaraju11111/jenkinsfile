pipeline {
    agent { label 'UBUNTU-NODE' }
    triggers { pollSCM('*/60 * * * *') }
    parameters { choice(name: 'BRANCH_TO_BUILD', choices: ['main', 'ppm', 'ppm2'], description: 'to choose branch') 
                 choice(name: 'maven_goal', choices: ['clean', 'package', 'deploy'], description: 'to choose goal')
               }
    stages {
        stage('git') {
            steps {
                git url: 'https://github.com/Nagaraju11111/spring-petclinic.git',
                    branch: "${params.BRANCH_TO_BUILD}"
            }
        }
        stage('maven') {
            steps {
                sh "mvn ${params.maven_goal}"
            }
        }
        stage('Archive JUnit formatted test results') {
            steps {
                junit testResults: '**/surefire-reports/*.xml'
            }
        }
       stage('Archiva artifacts') {
            steps {
                archiveArtifacts artifacts: '**/target/*.jar'
            }
        } 
    }
}
