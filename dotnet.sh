pipeline {
    agent { label 'NODE'}
    stages {
        stage('vcs') {
            steps {
                git url: 'https://github.com/GitPracticeRepo/dotnetcore-docs-hello-world.git'
            }
        }
        stage('build') {
            steps {
                sh 'dotnet build'
            }
        }
        stage('publish') {
            steps {
                sh 'dotnet publish'
            }
        }
        stage('zip files') {
            steps {
                sh 'zip -r /home/jenkins/remote_root/workspace/DOTNET/bin/Debug/net6.0/dotnetproject.zip /home/jenkins/remote_root/workspace/DOTNET/bin/Debug/net6.0/publish'
            }
        }
        stage('archive artifacts') {
            steps {
                rtUpload (
                    serverId: 'JFROG-AC',
                    spec: '''{
                        "files": [
                    {
                        "pattern": "dotnetproject.zip",
                        "target": "npm-default-local"
                    }
                        ]
                    }''',
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