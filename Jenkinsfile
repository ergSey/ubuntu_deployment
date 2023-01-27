pipeline {
    environment {
        TEST_VAR = "MaVar"
    }
    agent any
    parameters {
        booleanParam(name: "DEPLOY", defaultValue: true, description: "Деплой?")
        string(name: "BUILD", defaultValue: "DRY_RUN", trim: true, description: "Введите тип сборки")
        choice(name: "branch", choices: ["master", "hotfix", "develop", "master"], description: "Выберити ветку сборки")
        choice(name: "Characters", choices: ["a", "b", "c"], description: 'name of the student')
    }

    stages{

        stage ('checkout') {
            steps{
                git branch: 'master', url: 'https://github.com/ergSey/ubuntu_deployment.git'
                sh 'env | egrep -i "DEPLOY|BUILD|branch"'
            }
        }

        stage('Master Branch Tasks') {
            when {
                branch 'master'
            }

            steps {
                sh 'echo "Its OKOKKdK"'
            }
    }
}
