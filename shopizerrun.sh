pipeline {
    agent any
    parameters { string(name: 'maven_goal', defaultValue: 'install', description: 'install the package') }
    triggers { pollSCM('H */4 * * 1-5') }
    stages {
        stage('git') {
            steps {
                 mail subject: "Build started for shopizer JOB $env.JOB_NAME",
                      body: "Build started for shopizer JOB $env.JOB_NAME with build id $env.BUILD_ID",
                      to: "ppmjenkins@gmail.com"
                git url: 'https://github.com/shopizer-ecommerce/shopizer.git',
                    branch: 'master'
            }
        }
        stage ('Artifactory configuration') {
            steps {
                rtMavenDeployer (
                    id: "MAVEN_DEPLOYER",
                    serverId: "JFROG-AC",
                    releaseRepo: 'default-libs-release-local',
                    snapshotRepo: 'default-libs-snapshot-local'
                )
           }
        }
        stage ('Exec Maven') {
            steps {
                rtMavenRun (
                    tool: 'MAVEN-3.6.3', // Tool name from Jenkins configuration
                    pom: 'pom.xml',
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
    post {
        always {
            mail subject: "Build completed for shopizer JOB $env.JOB_NAME",
                 body: "Build completed for shopizer JOB $env.JOB_NAME \n click here: $env.JOB_URL",
                 to: "ppmjenkins@gmail.com"
        }
        failure {
            mail subject: "Build failed for shopizer JOB $env.JOB_NAME",
                 body: "Build failed for shopizer JOB $env.JOB_NAME with build id $env.BUILD_ID",
                 to: "ppmjenkins@gmail.com"
        }
        success {
            junit testResults: '**/target/surefire-reports/*.xml'
        }
    }
}
