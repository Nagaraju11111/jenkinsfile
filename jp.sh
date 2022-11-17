pipeline {
    agent { label 'UBUNTU-NODE' }
    triggers { pollSCM('*/60 * * * *') }
    parameters { choice(name: 'BRANCH_TO_BUILD', choices: ['main', 'ppm', 'ppm2'], description: 'to choose branch') 
                 string(name: 'maven_goal', defaultValue: 'package', description: 'build the code')
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
