pipeline {
    agent any
    parameters {  
                 string(name: 'maven_goal', defaultValue: 'clean install', description: 'build the code')
                }
    
    stages {
        stage ('vcs') {
            steps {
                git branch: 'main', url: "https://github.com/spring-projects/spring-petclinic.git"
            }
        }

        stage ('Artifactory configuration') {
            steps {
                rtMavenDeployer (
                    id: "MAVEN_DEPLOYER",
                    serverId: "JFROG_PRACTICE",
                    releaseRepo: "naveen-libs-release-local",
                    snapshotRepo: "naveen-libs-snapshot-local"
                )
            }
        }
        stage("build & SonarQube analysis") {
            steps {
              withSonarQubeEnv('SONARQUBE_PRACTICE') {
                sh 'mvn clean package sonar:sonar'
              }
            }
          }
          stage("Quality Gate") {
            steps {
              timeout(time: 30, unit: 'MINUTES') {
                waitForQualityGate abortPipeline: true
              }
            }
          }
        stage ('Exec Maven') {
            steps {
                rtMavenRun (
                    tool: "MAVEN-3.6.3", // Tool name from Jenkins configuration
                    pom: "pom.xml",
                    goals: 'clean install',
                    deployerId: "MAVEN_DEPLOYER"
                )
            }
        }
        stage ('Publish build info') {
            steps {
                rtPublishBuildInfo (
                    serverId: "JFROG_PRACTICE"
                )
            }
        }
    }
}
