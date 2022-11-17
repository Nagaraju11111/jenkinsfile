pipeline {
    agent none 
    stages {
        stage('vcs') {
             
            steps {
                git url: "urlname",
                     branch: "main"
            }
        }
        stage('build') {
             
            steps {
                sh scipt: "mvn package"
            }
        }
        stage('artifacts') {
             
            steps {
                archive includes: "mvn package"
            }
        }
    }
}
