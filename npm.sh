pipeline {
    agent { label 'NODE' }     
    stages {
        stage('vcs') {
            steps {
                git url: 'https://github.com/GitPracticeRepo/js-e2e-express-server.git',
                    branch: 'main'

        }
        }
        stage('build') {
            steps {
                sh "npm install npm run build"
            }
        }
        stage ('Artifactory configuration') {
            steps {
                
                rtNpmDeployer (
                    id: "NPM_DEPLOYER",
                    serverId: "JFROG-AC",
                    repo: "npm-local"
                )
            }
        }

        stage ('Exec npm install') {
            steps {
                rtNpmInstall (
                    tool: NPM_TOOL, // Tool name from Jenkins configuration
                    path: "npm-example",
                    resolverId: "NPM_RESOLVER"
                )
            }
        }

        stage ('Exec npm publish') {
            steps {
                rtNpmPublish (
                    tool: NPM_TOOL, // Tool name from Jenkins configuration
                    path: "npm-example",
                    deployerId: "NPM_DEPLOYER"
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