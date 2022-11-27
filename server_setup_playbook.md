# Mest en log af hvad jeg laver på serveren

Så jeg kan gentage det på en anden maskine...


## Ubuntu server

Jeg har allerede lavet en grundinstallation af Ubuntu server 22.04.1 LTS

Jeg har ssh connection med user `soren`, pw `*******` på local ip `192.168.0.14`

    $ ssh 192.168.0.14
        soren@192.168.0.14's password: 
        Welcome to Ubuntu 22.04.1 LTS (GNU/Linux 5.15.0-53-generic x86_64)

        * Documentation:  https://help.ubuntu.com
        * Management:     https://landscape.canonical.com
        * Support:        https://ubuntu.com/advantage

        System information as of Mon Nov 21 06:18:55 PM UTC 2022

        System load:  0.07861328125     Temperature:             43.0 C
        Usage of /:   7.9% of 97.87GB   Processes:               157
        Memory usage: 1%                Users logged in:         0
        Swap usage:   0%                IPv4 address for wlp4s0: 192.168.0.14


        0 updates can be applied immediately.


        Last login: Mon Nov 21 18:09:00 2022 from 192.168.0.3

### Update, Upgrade

Jeg opdaterer naturligtvis

    sudo apt update
    sudo apt upgrade -y

### Har rodet lidt med power management
Men ikke helt konsistent...

    sudo apt install pm-utils 

## Airflow

Man installarer bare airflow som en PiPy pakke.  
Se 
* <https://airflow.apache.org/docs/apache-airflow/stable/installation/installing-from-pypi.html> 

Men det er også _nice_ at have det i et virtuel environment...



Til dette er jeg inspireret af 
* https://medium.com/international-school-of-ai-data-science/setting-up-apache-airflow-in-ubuntu-324cfcee1427

Og for at oprette en service (eller to)  
* <https://medium.com/@shahbaz.ali03/run-apache-airflow-as-a-service-on-ubuntu-18-04-server-b637c03f4722>
som godt nok er en anden version af ubuntu, men det går nok :-D

Men inden, skal jeg lige...

Airflow installeres og køres direkte i en undermappe under brugerens hjemme-mappe. (F.eks `~/airflow/`)

Derfor  vil jeg hellere køre Airflow som sin egen bruger `airflow`.

    $ sudo useradd -s /usr/bin/bash -m --password wolfria airflow

Dernæst

    $ sudo ls -la /home/airflow/
    total 20
    drwxr-x--- 2 airflow airflow 4096 Nov 21 20:25 .
    drwxr-xr-x 4 root    root    4096 Nov 21 20:25 ..
    -rw-r--r-- 1 airflow airflow  220 Feb 25  2020 .bash_logout
    -rw-r--r-- 1 airflow airflow 3771 Feb 25  2020 .bashrc
    -rw-r--r-- 1 airflow airflow  807 Feb 25  2020 .profile

#### su airflow

Herfra, og indtil videre, skifter jeg til at køre som airflow...

    soren@databankairflow:~$ sudo su - airflow
    airflow@databankairflow:~$ _ 

### installing pi, virtualenv ...

VIdere med <https://medium.com/international-school-of-ai-data-science/setting-up-apache-airflow-in-ubuntu-324cfcee1427>

    sudo apt install python3-pip

hmm virker ikke ... tilføjer `airflow` til gruppen `sudo`. Skal måske fjernes når i drift...

    sudo usermod -aG sudo airflow

hmmm

installerer bare `sudo`-ting under bruger `soren`. Det er alligevel som `root` i sidste ende, pga `sudo`

    sudo apt install python3-pip
    sudo pip3 install virtualenv

tilbage som `airflow`-bruger

    virtualenv airflow_env

        created virtual environment CPython3.10.6.final.0-64 in 655ms
        creator CPython3Posix(dest=/home/airflow/airflow_env, clear=False, no_vcs_ignore=False, global=False)
        seeder FromAppData(download=False, pip=bundle, setuptools=bundle, wheel=bundle, via=copy, app_data_dir=/home/airflow/.local/share/virtualenv)
            added seed packages: pip==22.3.1, setuptools==65.5.1, wheel==0.38.4
        activators BashActivator,CShellActivator,FishActivator,NushellActivator,PowerShellActivator,PythonActivator        

og
    
    source airflow_env/bin/activate

    (airflow_env) airflow@databankairflow:~$


### installer airflow

Ovenstående vejeledning (<https://medium.com/international-school-of-ai-data-science/setting-up-apache-airflow-in-ubuntu-324cfcee1427>) anbefaler at installere med 

    pip3 install apache-airflow[gcp,sentry,statsd]

som ikke er det samme som airflow vejledning (<https://airflow.apache.org/docs/apache-airflow/stable/installation/installing-from-pypi.html>), som anbefaler:

    pip install "apache-airflow[celery]==2.4.3" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.4.3/constraints-3.7.txt"

Jeg prøver den første og ser hvad der sker...

---------

Jeg forventede at der skulle være en mappe `~/airflow`. Men det er der ikke...


JEg dropper virtualenv for nu

# forfra på virtual box

user soren, password ********

## Bruger _Air_

    $ sudo useradd -m -s /usr/bin/bash air
    $ sudo passwd air 
        New password:           [ria]
        Retype new password:    [ria]
    $ sudo su - air

    air@upair:~$

## _Soren_ Python

Python er installeret. Dog som `python3`.

    soren@ubair:~$ python3 --version
        Python 3.10.6

Så jeg installerer `python-is-python3`

    $ sudo apt install python-is-python3 

og pip

    $ pip --version
        Command 'pip' not found, but can be installed with:
        sudo apt install python3-pip

    $ sudo apt install python3-pip

    $ pip --version
        pip 22.0.2 from /usr/lib/python3/
        dist-packages/pip (python 3.10)

    $ pip3 --version
        pip 22.0.2 from /usr/lib/python3/  
        dist-packages/pip (python 3.10)

## _Air_ pip install

jeg kører `pip install ...` fra en shell-fil, fordi der er mange ekstra parametre...

    $ vim install_airflow_core.sh

```bash
PATH=$PATH:~/.local/bin
AIRFLOW_VERSION=2.4.3
PYTHON_VERSION="$(python --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
# For example: 3.7
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-no-providers-${PYTHON_VERSION}.txt"
# For example: https://raw.githubusercontent.com/apache/airflow/constraints-2.4.3/constraints-no-providers-3.7.txt
pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}
```

    $ chmod u+x install_airflow_core.sh 

og 

    $ ls -l
        total 4
        -rwxrw-r-- 1 air air 481 Nov 23 20:41 install_airflow_core.sh

Så, nu kan jeg køre scriptet, som laver en masse outpu, for der installeres mange pakker som airflow er afhængig af.

    $ ./install_airflow_core.sh 

```bash
    ...
    Installing collected packages: unicodecsv, text-unidecode, rfc3986, pytz, lockfile, cron-descriptor, commonmark, colorlog, wrapt, urllib3, uc-micro-py, typing-extensions, termcolor, tenacity, tabulate, sqlparse, sniffio, setproctitle, PyYAML, pytzdata, python-slugify, python-dateutil, pyrsistent, pyparsing, pyjwt, pygments, pycparser, psutil, prison, pluggy, pathspec, mdurl, markupsafe, markdown, lazy-object-proxy, itsdangerous, inflection, idna, h11, gunicorn, greenlet, graphviz, exceptiongroup, docutils, dnspython, dill, configupdater, colorama, click, charset-normalizer, certifi, cachelib, blinker, Babel, attrs, argcomplete, apispec, apache-airflow-providers-imap, apache-airflow-providers-ftp, WTForms, werkzeug, sqlalchemy, rich, requests, python-daemon, pendulum, packaging, markdown-it-py, Mako, linkify-it-py, jsonschema, jinja2, email-validator, deprecated, croniter, clickclick, cffi, cattrs, apache-airflow-providers-common-sql, anyio, swagger-ui-bundle, sqlalchemy-utils, sqlalchemy-jsonfield, requests-toolbelt, python-nvd3, mdit-py-plugins, marshmallow, httpcore, flask, cryptography, apache-airflow-providers-sqlite, alembic, marshmallow-sqlalchemy, marshmallow-oneofschema, marshmallow-enum, httpx, flask-wtf, Flask-SQLAlchemy, flask-session, flask-login, Flask-JWT-Extended, flask-caching, Flask-Babel, connexion, apache-airflow-providers-http, flask-appbuilder, apache-airflow
    Successfully installed Babel-2.11.0 Flask-Babel-2.0.0 Flask-JWT-Extended-4.4.4 Flask-SQLAlchemy-2.5.1 Mako-1.2.3 PyYAML-6.0 WTForms-3.0.1 alembic-1.8.1 anyio-3.6.2 apache-airflow-2.4.3 apache-airflow-providers-common-sql-1.3.0 apache-airflow-providers-ftp-3.2.0 apache-airflow-providers-http-4.1.0 apache-airflow-providers-imap-3.1.0 apache-airflow-providers-sqlite-3.3.0 apispec-3.3.2 argcomplete-2.0.0 attrs-22.1.0 blinker-1.5 cachelib-0.9.0 cattrs-22.2.0 certifi-2022.9.24 cffi-1.15.1 charset-normalizer-2.1.1 click-8.1.3 clickclick-20.10.2 colorama-0.4.6 colorlog-4.8.0 commonmark-0.9.1 configupdater-3.1.1 connexion-2.14.1 cron-descriptor-1.2.31 croniter-1.3.7 cryptography-36.0.2 deprecated-1.2.13 dill-0.3.2 dnspython-2.2.1 docutils-0.19 email-validator-1.3.0 exceptiongroup-1.0.1 flask-2.2.2 flask-appbuilder-4.1.4 flask-caching-2.0.1 flask-login-0.6.2 flask-session-0.4.0 flask-wtf-1.0.1 graphviz-0.20.1 greenlet-2.0.1 gunicorn-20.1.0 h11-0.12.0 httpcore-0.15.0 httpx-0.23.0 idna-3.4 inflection-0.5.1 itsdangerous-2.1.2 jinja2-3.1.2 jsonschema-4.17.0 lazy-object-proxy-1.8.0 linkify-it-py-2.0.0 lockfile-0.12.2 markdown-3.4.1 markdown-it-py-2.1.0 markupsafe-2.1.1 marshmallow-3.18.0 marshmallow-enum-1.5.1 marshmallow-oneofschema-3.0.1 marshmallow-sqlalchemy-0.26.1 mdit-py-plugins-0.3.1 mdurl-0.1.2 packaging-21.3 pathspec-0.9.0 pendulum-2.1.2 pluggy-1.0.0 prison-0.2.1 psutil-5.9.4 pycparser-2.21 pygments-2.13.0 pyjwt-2.6.0 pyparsing-3.0.9 pyrsistent-0.19.2 python-daemon-2.3.2 python-dateutil-2.8.2 python-nvd3-0.15.0 python-slugify-6.1.2 pytz-2022.6 pytzdata-2020.1 requests-2.28.1 requests-toolbelt-0.10.1 rfc3986-1.5.0 rich-12.6.0 setproctitle-1.3.2 sniffio-1.3.0 sqlalchemy-1.4.43 sqlalchemy-jsonfield-1.0.0 sqlalchemy-utils-0.38.3 sqlparse-0.4.3 swagger-ui-bundle-0.0.9 tabulate-0.9.0 tenacity-8.1.0 termcolor-2.1.0 text-unidecode-1.3 typing-extensions-4.4.0 uc-micro-py-1.0.1 unicodecsv-0.14.1 urllib3-1.26.12 werkzeug-2.2.2 wrapt-1.14.1

```

SÅ nu ...

    ls -la 
        total 40
        drwxr-x--- 4 air  air  4096 Nov 23 20:48 .
        drwxr-xr-x 4 root root 4096 Nov 23 18:44 ..
        -rw------- 1 air  air    13 Nov 23 18:52 .bash_history
        -rw-r--r-- 1 air  air   220 Jan  6  2022 .bash_logout
        -rw-r--r-- 1 air  air  3771 Jan  6  2022 .bashrc
        drwxrwxr-x 3 air  air  4096 Nov 23 20:43 .cache
        -rwxrw-r-- 1 air  air   481 Nov 23 20:41 install_airflow_core.sh
        drwxrwxr-x 6 air  air  4096 Nov 23 20:48 .local
        -rw-r--r-- 1 air  air   807 Jan  6  2022 .profile
        -rw------- 1 air  air   841 Nov 23 20:41 .viminfo

bemærk mappen `.local`, altså i bruger mappen: `~/.local`:

    $ ls ~/.local -l
        total 16
        drwxrwxr-x 3 air air 4096 Nov 23 20:48 bin
        drwxrwxr-x 2 air air 4096 Nov 23 20:48 generated
        drwxrwxr-x 3 air air 4096 Nov 23 20:48 include
        drwxrwxr-x 3 air air 4096 Nov 23 20:48 lib

og i undermappen `bin`:

    air@ubair:~$ ls ~/.local/bin/ -l
        total 160
        -rwxrwxr-x 1 air air 3472 Nov 23 20:48 activate-global-python-argcomplete
        -rwxrwxr-x 1 air air  215 Nov 23 20:48 airflow
        -rwxrwxr-x 1 air air  213 Nov 23 20:48 alembic
        -rwxrwxr-x 1 air air  215 Nov 23 20:48 cmark
        -rwxrwxr-x 1 air air  212 Nov 23 20:48 connexion
        -rwxrwxr-x 1 air air  216 Nov 23 20:48 docutils
        -rwxrwxr-x 1 air air  214 Nov 23 20:48 email_validator
        -rwxrwxr-x 1 air air  221 Nov 23 20:48 fabmanager
        -rwxrwxr-x 1 air air  208 Nov 23 20:48 flask
        -rwxrwxr-x 1 air air 1651 Nov 23 20:48 get_objgraph
        -rwxrwxr-x 1 air air  217 Nov 23 20:48 gunicorn
        -rwxrwxr-x 1 air air  204 Nov 23 20:48 httpx
        -rwxrwxr-x 1 air air  213 Nov 23 20:48 jsonschema
        -rwxrwxr-x 1 air air  213 Nov 23 20:48 mako-render
        -rwxrwxr-x 1 air air  220 Nov 23 20:48 markdown-it
        -rwxrwxr-x 1 air air  214 Nov 23 20:48 markdown_py
        -rwxrwxr-x 1 air air  244 Nov 23 20:48 normalizer
        -rwxrwxr-x 1 air air  215 Nov 23 20:48 nvd3
        -rwxrwxr-x 1 air air  222 Nov 23 20:48 pybabel
        drwxrwxr-x 2 air air 4096 Nov 23 20:48 __pycache__
        -rwxrwxr-x 1 air air  215 Nov 23 20:48 pygmentize
        -rwxrwxr-x 1 air air 2555 Nov 23 20:48 python-argcomplete-check-easy-install-script
        -rwxrwxr-x 1 air air  383 Nov 23 20:48 python-argcomplete-tcsh
        -rwxrwxr-x 1 air air 1917 Nov 23 20:48 register-python-argcomplete
        -rwxrwxr-x 1 air air  714 Nov 23 20:48 rst2html4.py
        -rwxrwxr-x 1 air air 1059 Nov 23 20:48 rst2html5.py
        -rwxrwxr-x 1 air air  592 Nov 23 20:48 rst2html.py
        -rwxrwxr-x 1 air air  791 Nov 23 20:48 rst2latex.py
        -rwxrwxr-x 1 air air  614 Nov 23 20:48 rst2man.py
        -rwxrwxr-x 1 air air 1718 Nov 23 20:48 rst2odt_prepstyles.py
        -rwxrwxr-x 1 air air  780 Nov 23 20:48 rst2odt.py
        -rwxrwxr-x 1 air air  599 Nov 23 20:48 rst2pseudoxml.py
        -rwxrwxr-x 1 air air  635 Nov 23 20:48 rst2s5.py
        -rwxrwxr-x 1 air air  871 Nov 23 20:48 rst2xetex.py
        -rwxrwxr-x 1 air air  600 Nov 23 20:48 rst2xml.py
        -rwxrwxr-x 1 air air  668 Nov 23 20:48 rstpep2html.py
        -rwxrwxr-x 1 air air  215 Nov 23 20:48 slugify
        -rwxrwxr-x 1 air air  216 Nov 23 20:48 sqlformat
        -rwxrwxr-x 1 air air  209 Nov 23 20:48 tabulate
        -rwxrwxr-x 1 air air  587 Nov 23 20:48 undill

her ligger ekskver bare filer. Bl.a. `airflow`.

    $ .local/bin/airflow --help
        usage: airflow [-h] GROUP_OR_COMMAND ...

        positional arguments:
        GROUP_OR_COMMAND

            Groups:
            celery         Celery components
            config         View configuration
            connections    Manage connections
            dags           Manage DAGs
            db             Database operations
            jobs           Manage jobs
            kubernetes     Tools to help run the KubernetesExecutor
            pools          Manage pools
            providers      Display providers
            roles          Manage roles
            tasks          Manage tasks
            users          Manage users
            variables      Manage variables

            Commands:
            cheat-sheet    Display cheat sheet
            dag-processor  Start a standalone Dag Processor instance
            info           Show information about current Airflow and environment
            kerberos       Start a kerberos ticket renewer
            plugins        Dump information about loaded plugins
            rotate-fernet-key
                            Rotate encrypted connection credentials and variables
            scheduler      Start a scheduler instance
            standalone     Run an all-in-one copy of Airflow
            sync-perm      Update permissions for existing roles and optionally DAGs
            triggerer      Start a triggerer instance
            version        Show the version
            webserver      Start a Airflow webserver instance

        options:
        -h, --help         show this help message and exit

Men altså, her har jeg skrevet hele path foran :-(. (`.local/bin/`, foran `airflow`).

#### path...

Jeg skal have kommandoen 

    export PATH=$PATH:~/.local/bin

ind et passende sted, `.profile` eller noget...
Hvis jeg kører den i konsollen, virker direkte path til `airflow`, men kun i denne konsol.

## Roadmap
* init db
* test standalone
* test individuelle processer
  * sheduler
  * webserver
  * trigger
  * ...
* storage
  * med adgang til indsamlede data
* adgang til at lægge dags/tasks op

##ToDO

* `export PATH=$PATH:~/.local/bin` i paassende start script. Helst så også services kan bruge det


## Fredag 26. nov

Prøver med virtuelle environments. Konkret `venv`.

Se <https://python.land/virtual-environments/virtualenv>

    sudo apt install python3.10-venv

dernæst

```bash
cd ~
mkdir airflow
cd airflow
python -m venv air
source air/bin/activate
```

herafter alle kommandoerne i `install_core.sh`

    chmod u+x install_core.sh 

`install_core.sh`:
```bash
# Airflow needs a home. `~/airflow` is the default, but you can put it
# somewhere else if you prefer (optional)
export AIRFLOW_HOME=~/airflow

AIRFLOW_VERSION=2.4.3
PYTHON_VERSION="$(python --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
# For example: 3.7
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-no-providers-${PYTHON_VERSION}.txt"
# For example: https://raw.githubusercontent.com/apache/airflow/constraints-2.4.3/constraints-no-providers-3.7.txt
pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"

```
En kombi af 
* <https://airflow.apache.org/docs/apache-airflow/stable/start.html> og 
* <https://airflow.apache.org/docs/apache-airflow/stable/installation/installing-from-pypi.html>

## YES!

Nu kan vi køre `airflow` kommandoer!

f.eks.
    
    airflow --help

og 

    airflow infor

### start af ariflow

    airflow db init

i standalone mode

    airflow standalone 

eller måske 

    ariflow standalone &


## Eller installer med pip som root

Inspirreret af Christopher Tao's <https://towardsdatascience.com/how-to-run-apache-airflow-as-daemon-using-linux-systemd-63a1d85f9702>

Han lægger op til at installere med `pip install` som root... det advarer pip imod, men alternativet er at bruge `venv` og det har jeg ikke rigtigt styr på med `system.d` og alt det...

jeg har samlet scriptet `install_core.sh` nævnt ovenfor.
Det kører jeg nu som root:

    cd airflow
    sudo ./install_core.sh

det kan jeg så checke med 

    $ which airflow
        /usr/local/bin/airflow

Så nu er Airflow installeret i `/usr/local/bin`!
**Läcker!**


Ahilleus gør noget lignende (meget meget mere forsimplet) men med anaconda til at lave virtuelle env. Det er interessant til `venv` måske <https://medium.com/@achilleus/easy-way-to-manage-your-airflow-setup-b7c030dd1cb8>