pipeline {
    agent { label 'NODE' }
    parameters { string(name: 'maven_goal', defaultValue: 'install', description: 'install the package') }
    triggers { pollSCM('H */4 * * 1-5') }
    stages {
        stage('git') {
            steps {
                 mail subject: "jenkins job started for shopizer $env.JOB_NAME",
                      body: "jenkins job started for shopizer $env.JOB_NAME with build id $env.BUILD_ID",
                      to: "ppmjenkins@gmail.com"
                git url: 'https://github.com/shopizer-ecommerce/shopizer.git',
                    branch: 'master'
            }
        }
        stage("build & SonarQube analysis") {
            steps {
              withSonarQubeEnv('SONARQUBE-PRACTICE') {
                sh 'mvn clean package sonar:sonar'
              }
            }
          }
          stage("Quality Gate") {
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
            }
          }
        stage('maven') {
            steps {
                sh script: "mvn ${params.maven_goal}"
            }
        }
        stage ('Artifactory configuration') {
            steps {
                rtMavenDeployer (
                    id: "MAVEN_DEPLOYER",
                    serverId: "JFROG-PRACTICE",
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
                    serverId: "JFROG-PRACTICE"
                )
            }
        }
    }
    post {
        always {
            mail subject: "jenkins job completed for shopizer $env.JOB_NAME",
                 body: "jenkins job completed for shopizer $env.JOB_NAME \n click here: $env.JOB_URL",
                 to: "ppmjenkins@gmail.com"
        }
        failure {
            mail subject: "jenkins job failed for shopizer $env.JOB_NAME",
                 body: "jenkins job failed for shopizer $env.JOB_NAME with build id $env.BUILD_ID",
                 to: "ppmjenkins@gmail.com"
        }
        success {
            junit testResults: '**/target/surefire-reports/*.xml'
        }
    }
}

