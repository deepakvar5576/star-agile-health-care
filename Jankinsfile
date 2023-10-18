pipeline {

    agent { label 'jenkins-slave' }
	
    tools {
        maven "Apache Maven 3.6.3"
    }

	environment {	
		DOCKERHUB_CREDENTIALS=credentials('project-banking-app')
	}
	
    stages {
        stage('SCM_Checkout') {
            steps {
                echo 'Perform SCM Checkout'
				git 'https://github.com/deepakvar5576/star-agile-health-care.git'
            }
        }
        stage('Application_Build') {
            steps {
                echo 'Perform Maven Build'
				sh 'mvn -Dmaven.test.failure.ignore=true clean package'
            }
			  post {
				failure {
				  sh "echo 'Send mail on failure'"
				  mail to:"dddeepakvarshney5575@gmail.com", from: 'dddeepakvarshney5575@gmail.com', subject:"FAILURE: ${currentBuild.fullDisplayName}", body: "Build failed."
				}
			  }
        }
        stage('Build Docker Image') {
            steps {
				sh 'docker version'
				sh "docker build -t deepakvarshney5576/health-care-app:${BUILD_NUMBER} ."
				sh 'docker image list'
				sh "docker tag deepakvarshney5576/health-care-app:${BUILD_NUMBER} deepakvarshney5576/health-care-app:latest"
            }
              post {
                success {
                  sh "echo 'Send mail docker Build Success'"
                  mail to:"dddeepakvarshney5575@gmail.com", from: 'dddeepakvarshney5575@gmail.com', subject:"App Image Created Please validate", body: "App Image Created Please validate - loksaieta/loksai-eta-app1:latest"
                }
                failure {
                  sh "echo 'Send mail docker Build failure'"
                  mail to:"dddeepakvarshney5575@gmail.com", from: 'dddeepakvarshney5575@gmail.com', subject:"FAILURE: ${currentBuild.fullDisplayName}", body: "Image Build failed."
                }
              }	
        }
        stage('Approve - push Image to dockerhub'){
            steps{
                
                //----------------send an approval prompt-------------
                script {
                   env.APPROVED_DEPLOY = input message: 'User input required Choose "Yes" | "Abort"'
                       }
                //-----------------end approval prompt------------
            }
        }
		stage('Login2DockerHub') {

			steps {
				sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
			}
		}
		stage('Publish_to_Docker_Registry') {
			steps {
				sh "docker push deepakvarshney5576/health-care-app:latest"
			}
		}
		stage('Deploy to Kubernetes_Cluster') {
			steps {
				script {
					sshPublisher(publishers: [sshPublisherDesc(configName: 'kubernetes', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: 'kubectl apply -f healthdeployment.ymal', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '.', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '*.ymal')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
				}
			}
		}
    }
}									
