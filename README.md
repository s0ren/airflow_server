# Airflow Server

Noter og scripts tiol opsætninge af Airflow server til brug for BigData på TEC.

Den skal køre på en Ubuntu Server 22.04.1.

Måske også som Docker-compose ting til eleverne, på elevernes, til udvikling og afprøvning.

Se [`install.sh`](install.sh) for resultatet, til brug på Ubuntu.

For docker opsæting, se [`docker-compose.yaml`](docker-compose.yaml), for docker.

Se [`server_setup_playbook.md`](server_setup_playbook.md), for processen og kilder.


# TODO

  - [x] Lav resume med alle kommandoer
  - [x] Opret det hele på tec/thomas server
  - [ ] skift til postgresql
    - <https://airflow.apache.org/docs/apache-airflow/2.4.3/howto/set-up-database.html>
  - [ ] skift til noget med en anden executer end SequentialExecutor
    - `Do not use SequentialExecutor in production. Click here for more information.` <https://airflow.apache.org/docs/apache-airflow/2.4.3/executor/index.html>
 - [ ] Storage af haul/loot (indhentet data) på noget S3 el.lign
  - [ ] check docker images