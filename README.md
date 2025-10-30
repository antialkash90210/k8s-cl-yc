# Убедитесь, что у вас установлены Terraform, Yandex Cloud CLI и настроен аккаунт в Yandex Cloud.

# Скопировать проект
git clone git@github.com:antialkash90210/k8s-cluster-yc.git
cd k8s-cl-yc/

# Выводит все параметры текущего активного профиля конфигурации
yc config list

# Добавить свои значения конфигурации
nano terraform.tfvars

# Сделать файлы исполняемыми
chmod +x get-node-ips.sh
chmod +x setup-cluster.sh
chmod +x ssh-to-node.sh
chmod +x destroy-cluster.sh

# Команды для работы с Terraform
#Инициализация
terraform init
#Планирование
terraform plan
#Применение
terraform apply

# Запуск скриптов
./get-node-ips.sh
./setup-cluster.sh
./ssh-to-node.sh
./destroy-cluster.sh
