# show all commands:
set -x 

# update ubuntu
echo "Update ubuntu"
apt update
apt upgrade -y

# install required packeages
apt-get install python-dev libsasl2-dev gcc 
apt-get install libffi-dev 
apt-get install libkrb5-dev 
apt install virtualenv

# bruger til at køre airflow services
useradd airflow

# Klargør mapper til config
# mappen `/etc/sysconfig/` findes ikke (på ubuntu, tror jeg) så den opretter vi 

mkdir /etc/sysconfig/

# postgit_fetch.sh
## skal lige have exec med `chmod u+x post_git_fetch.sh`
cp -r files/. symlinks/. 

mkdir /run/airflow
chown airflow:airflow /run/airflow
chmod 0755 /run/airflow -R

mkdir /opt/airflow
chown airflow:airflow /opt/airflow -R
chmod 775 /opt/airflow -R


# install_core.sh 
## Airflow needs a home. `~/airflow` is the default, but you can put it
## somewhere else if you prefer (optional)
export AIRFLOW_HOME=/opt/airflow

AIRFLOW_VERSION=2.4.3
PYTHON_VERSION="$(python --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
# For example: 3.7
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-no-providers-${PYTHON_VERSION}.txt"
# For example: https://raw.githubusercontent.com/apache/airflow/constraints-2.4.3/constraints-no-providers-3.7.txt
pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"

# initializer database
sudo -u airflow AIRFLOW_HOME=/opt/airflow airflow db init

## starter service og opsætter til at starte v. boot
systemctl enable --now airflow-scheduler.service 
systemctl enable --now airflow-webserver.service 

#checker 
systemctl status airflow-scheduler.service --no-pager
journalctl -u airflow-scheduler -n 50 --no-pager
systemctl status airflow-webserver.service --no-pager
journalctl -u airflow-webserver -n 50 --no-pager

# create an airflow admin user
echo "creates user with password = 'password'. Please change later"
sudo -u airflow AIRFLOW_HOME=/opt/airflow airflow users create \
    --username smag \
    --firstname Søren \
    --lastname Magnusson \
    --role Admin \
    --email smag@tec.dk
    --password password

# timezone might be off
timedatectl set-timezone Europe/Copenhagen