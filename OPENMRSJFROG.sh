pipeline {
    agent any
    parameters {  
                 string(name: 'MAVEN_GOAL', defaultValue: 'clean install', description: 'build the code')
                }
    stages {
        stage ('vcs') {
            steps {
                git branch: 'master', 
                    url: "https://github.com/openmrs/openmrs-core.git"
            }
        }
        stage ('Artifactory configuration') {
            steps {
                rtMavenDeployer (
                    id: "MAVEN_DEPLOYER",
                    serverId: "JFROG-AC",
                    releaseRepo: "default-libs-release-local",
                    snapshotRepo: "default-libs-snapshot-local"
                )
            }
        }
        stage ('Exec Maven') {
            steps {
                rtMavenRun (
                    tool: 'MAVEN-3.6.3', // Tool name from Jenkins configuration
                    pom: "pom.xml",
                    goals: 'clean install',
                    deployerId: "MAVEN_DEPLOYER"
                )
            }
        }
        stage ('Publish build info') {
            steps {
                rtPublishBuildInfo (
                    serverId: "JFROG-AC"
                )
            }
        }
    }
}