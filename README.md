# Убедитесь, что у вас установлены Terraform, Yandex Cloud CLI и настроен аккаунт в Yandex Cloud.

#Скопировать проект

git clone git@github.com:antialkash90210/k8s-cl-yc.git

cd k8s-cl-yc/


#Выводит все параметры текущего активного профиля конфигурации
yc config list


#Добавить свои значения конфигурации
nano terraform.tfvars


#Сделать файлы исполняемыми
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

<img width="813" height="602" alt="1" src="https://github.com/user-attachments/assets/e77344bc-2ba1-4c73-99d8-cdbfd3e7e705" />
<img width="1177" height="407" alt="2" src="https://github.com/user-attachments/assets/ab5fe4ab-2fc3-4d20-92e4-3dafe37bba71" />
<img width="1105" height="198" alt="3" src="https://github.com/user-attachments/assets/31c02b40-4305-4b8b-8f0e-b91cb0ead621" />
<img width="1828" height="323" alt="4" src="https://github.com/user-attachments/assets/60407e9a-31c0-4252-a735-464f7a6d8b0e" />
