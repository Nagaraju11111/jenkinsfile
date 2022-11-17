pipeline {
    agent { label 'UBUNTU-NODE' }
    triggers { pollSCM('*/60 * * * *') }
    parameters { choice(name: 'BRANCH_TO_BUILD', choices: ['main', 'ppm', 'ppm2'], description: 'to choose branch') 
                 string(name: 'maven_goal', defaultValue: 'package', description: 'build the code')
               }
    stages {
        stage('git') {
            steps {
                mail subject: "Build Started for Jenkins JOB $env.JOB_NAME", 
                     body: "Build Started for Jenkins JOB $env.JOB_NAME", 
                     to: 'ppmjenkins@gmail.com' 
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
                junit testResults: '**/target/surefire-reporst/*.xml'
            }
        }
       stage('Archiva artifacts') {
            steps {
                archive includes: '**/target/*.jar'
            }
        } 
    }
        post {
            always {
                mail subject: "Build Completed for Jenkins JOB $env.JOB_NAME", 
                     body: "Build Completed for Jenkins JOB $env.JOB_NAME \n Click Here: $env.JOB_URL",
                     to: 'ppmjenkins@gmail.com'

            }
            success {
                junit '**/surefire-reports/*.xml'
            }
            failure {
                mail subject: "Build Failed for Jenkins JOB $env.JOB_NAME with Build ID $env.BUILD_ID", 
                     body: "Build Failed for Jenkins JOB $env.JOB_NAME", 
                     to: 'ppmjenkins@gmail.com'
            }
        }
    }
