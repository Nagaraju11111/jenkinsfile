pipeline {
    agent { label 'NODE2' } 
    stages {
        stage('VCS') { 
            steps {
                git url: 'https://github.com/wakaleo/game-of-life.git',
                    branch: 'master'
            }
        }
        stage('build') {
            steps {
                sh "export PATH='/usr/lib/jvm/java-8-openjdk-amd64/jre/bin:$PATH' mvn package"
            }
        }
        stage('Archive JUnit-formatted test results') {
            steps {
                junit '**/target/surefire-reports/*.xml'
            }
        }
        stage('Archive artifacts') {
            steps {
                archive '**/target/*.war'
            }
        }
    }
}