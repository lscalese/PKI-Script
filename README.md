## PKI-Script

This lib allow to perform steps related to Public Key Infrastructure described in this [community article](https://community.intersystems.com/post/creating-ssl-enabled-mirror-intersystems-iris-using-public-key-infrastructure-pki) without manual intervention.  Could be useful for scripting certificate generation.  



## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/lscalese/PKI-Script.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

## How to Test it

### Configure the server instance

Open IRIS terminal:

```bash
docker exec -it pki-script_iris_1 irissession iris
```

```Objectscript
Set sc = ##class(lscalese.pki.Server).MinimalServerConfig("$server_password$", "US", "CASrv", 365)
Do:'sc $SYSTEM.Status.DisplayError(sc)
; Sign all requested certificate from "client" hostname for 15 minutes : 
Do ##class(lscalese.pki.Server).SignAllRequestWhile("$server_password$",900,"client") ; could be started with Job command instead "Do"
```
### Configure the client instance

Open IRIS terminal:

```bash
docker exec -it pki-script_client_1 irissession iris
```

```Objectscript
Set sc = ##class(lscalese.pki.Client).MinimalClientConfig("iris:52773","Contact Name")
Do:'sc $SYSTEM.Status.DisplayError(sc)
```

### Request and get a new certificate

```Objectscript
Set sc = ##class(lscalese.pki.Client).RequestCertificate("$private_key$","US",,##class(lscalese.pki.Client).GenerateFilename()) ; request certificate
Do:'sc $SYSTEM.Status.DisplayError(sc)
Set sc = ##class(lscalese.pki.Client).WaitSigning(,,.number) ; Wait Authority server validation...
Do:'sc $SYSTEM.Status.DisplayError(sc)
Set sc = ##class(lscalese.pki.Client).GetRequestedCertificate(number)
Do:'sc $SYSTEM.Status.DisplayError(sc)
```


## How to start coding
This repository is ready to code in VSCode with ObjectScript plugin.
Install [VSCode](https://code.visualstudio.com/), [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) and [ObjectScript](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript) plugin and open the folder in VSCode.
Open /src/cls/PackageSample/ObjectScript.cls class and try to make changes - it will be compiled in running IRIS docker container.
![docker_compose](https://user-images.githubusercontent.com/2781759/76656929-0f2e5700-6547-11ea-9cc9-486a5641c51d.gif)

Feel free to delete PackageSample folder and place your ObjectScript classes in a form
/src/Package/Classname.cls
[Read more about folder setup for InterSystems ObjectScript](https://community.intersystems.com/post/simplified-objectscript-source-folder-structure-package-manager)

The script in Installer.cls will import everything you place under /src into IRIS.


## What's inside the repository

### Dockerfile

The simplest dockerfile which starts IRIS and imports code from /src folder into it.
Use the related docker-compose.yml to easily setup additional parametes like port number and where you map keys and host folders.


### .vscode/settings.json

Settings file to let you immedietly code in VSCode with [VSCode ObjectScript plugin](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript))

### .vscode/launch.json
Config file if you want to debug with VSCode ObjectScript

[Read about all the files in this artilce](https://community.intersystems.com/post/dockerfile-and-friends-or-how-run-and-collaborate-objectscript-projects-intersystems-iris)
