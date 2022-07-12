export MARIADB_PWD='teste123'

docker container run -dti --name banco_dados -v $(pwd)/db:/var/lib/mysql -e MARIADB_ROOT_PASSWORD=$MARIADB_PWD mariadb

docker container run -dti --name glpi_arquivos -v $(pwd)/www:/var/www/html/glpi busybox

docker container run -dti --name glpi --hostname glpi --link banco_dados:mariadb --volumes-from glpi_arquivos -p 80:80 diouxx/glpi



# rodando uma versão específica (recomendado para uso em ambiente de produção)

docker container run -dti --name glpi --hostname glpi --link banco_dados:mariadb -v $(pwd)/www:/var/www/html/glpi -p 80:80 --env "VERSION_GLPI=9.5.6" diouxx/glpi

