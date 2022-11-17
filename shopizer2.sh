pipeline {
    agent any
    parameters { string(name: 'maven_goal', defaultValue: 'install', description: 'install the package') }
    triggers { pollSCM('H */4 * * 1-5') }
    stages {
        stage('git') {
            steps {
                 mail subject: "jenkins job started for shopizer $env.JOB_NAME",
                      job: "jenkins job started for shopizer $env.JOB_NAME with build id $env.BUILD_ID",
                      to: "ppmjenkins@gmail.com"
                git url: 'https://github.com/shopizer-ecommerce/shopizer.git',
                    branch: 'master'
            }
        }
        stage('maven') {
            steps {
                sh script: "mvn ${params.maven_goal}"
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
    post {
        always {
            mail subject: "jenkins job completed for shopizer $env.JOB_NAME",
                 job: "jenkins job completed for shopizer $env.JOB_NAME \n click here: $env.JOB_URL",
                 to: "ppmjenkins@gmail.com"
        }
        failure {
            mail subject: "jenkins job failed for shopizer $env.JOB_NAME",
                 job: "jenkins job failed for shopizer $env.JOB_NAME with build id $env.BUILD_ID",
                 to: "ppmjenkins@gmail.com"
        }
        success {
            junit testResults: '**/target/surefire-reports/*.xml'
        }
    }

}
