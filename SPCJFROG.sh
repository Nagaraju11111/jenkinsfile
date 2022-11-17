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
                    serverId: "JFROG-PRACTICE",
                    releaseRepo: "naveen-libs-release-local",
                    snapshotRepo: "naveen-libs-snapshot-local"
                )
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
                    serverId: "JFROG-PRACTICE"
                )
            }
        }
    }
}
