# Docker - GLPI + MariaDB

Esta implantação leva em consideração que você já possui uma instância do banco de dados `MySQL/MariaDB` e o `GLPI` sob o `Apache` em um servidor **GNU/Linux** em produção e deseja migrar para o ambiente Docker.

## Passo 1 - Backup do banco de dados e GLPI

1. No servidor do banco de dados, faça um dump da sua base de dados atual:

   ```bash
   mysqldump -u root -p glpidbatual > backup.sql
   ```

2. Ainda no servidor, faça a cópia do diretório raiz do GLPI. Geralmente localizado em `/var/www/html/glpi`

## Passo 2 - Importação dos dados

1. No servidor Docker, faça um clone deste repositório:

   ```bash
   git clone https://github.com/kleberforte/docker-glpi-mariadb.git
   cd docker-glpi-mariadb
   ```

2. Copie o backup do banco de dados para o diretório (vazio) `db`

3. Copie os arquivos do GLPI para o diretório (vazio) `www`

4. Agora, vamos criar um container temporário para importar o nosso banco e ao mesmo tempo, persistir os dados do banco no diretório `db`

   ```bash
   # Altere a variável de ambiente MARIADB_ROOT_PASSWORD conforme as suas necessidades
   docker container run -dit --name banco_dados -v $(pwd)/db:/var/lib/mysql -e MARIADB_ROOT_PASSWORD=senhadobanco mariadb:10.8
   ```
   ```bash
   # Entrando no container
   docker container exec -it banco_dados /bin/bash
   ```
   ```bash
   # Criando o banco de dados
   mysql -u root -p
   CREATE DATABASE glpidb;
   CREATE USER 'glpi'@'%' IDENTIFIED BY 'minhasenha';
   GRANT ALL PRIVILEGES ON glpidb.* TO 'glpi'@'%' IDENTIFIED BY 'minhasenha'
   # Importando o banco (a senha é senhadobanco)
   mysql -u root -p glpidb < /var/lib/mysql/backup.sql
   ```
   ```bash
   # Saindo do container
   [ctrl] + [P] + [Q]
   # Removendo o container temporário
   docker container stop banco_dados && docker container rm banco_dados
   ```

## Passo 3 - Variáveis

Edite o arquivo `mariadb.env` com as credenciais de acesso ao banco criadas no passo 2:

```bash
MARIADB_ROOT_PASSWORD=senhadobanco
MARIADB_DATABASE=glpidb
MARIADB_USER=glpi
MARIADB_PASSWORD=minhasenha
```

## Passo 4 - Docker Compose

Agora basta executar a implantação presente no arquivo `docker-compose.yml`:

```bash
docker-compose up -d
```

Observações sobre o arquivo:

- Modifique a variável TIMEZONE que acordo com a sua região
