# Build dell'immagine

# Il . alla fine indica la cartella di contesto, cioè quella dove dovrebbe essere contenuto il Dockerfile
# La build dell'immagine può referenziare solo file che siano all'interno di tale cartella

# Qualche opzione di build:
# -t dichiara il nome dell'immagine
# --build-arg <param> permette di passare un argomento al dockerfile
# -f per specificare un dockerfile alternativo 
#     (il default è il file con nome Dockerfile all'interno della cartella di contesto)
# -v <cartella_host>:<cartella_container> monta un volume dentro al container
# --no-cache, esegue la build senza usare la cache delle build precedenti

docker build --build-arg WHO_TO_GREET="World" --build-arg WHO_TO_NOT_GREET="Moon" -t greetings .

# Eliminare un immagine
# In generale, per referenziare un oggetto docker si può usare anche il suo id
docker rmi <image_name>

# Run del container

# Il "greetings" alla fine indica il tag dell'immagine

# Qualche opzione di run:
# -d opera il detach dal processo, senza questo parametro il terminale rimarrebbe appesso sullo std output
# --name <param> da un nome al container
# --env | -e <param> imposta una variable d'ambiente nel container
# -p <host_port>:<conatiner_port> opera il port forwarding
# --network <param> connette il container ad una specifica sottorete
# --restart <param> cambia la strategia di riavvio del conatiner
# --rm funziona se non senza -d, ed elimina il container una volta staccati dallo std output con CRTL+C

docker run -d --name greeting -e SIMPLE_ENV="Yes, I'm here\!" -p 8081:8080 greetings

# Eliminare un container
# -f o --force server solo se il container è running
docker rm -f <container_name>

# Testare il server
# 1) Ritorna "Hello $WHO_TO_GREET!" -> "Hello World!"
curl -XGET http://localhost:8081/greet
# 2) Ritorna "Good by undefined", a dimostrazione del fatto che gli ARG rimangono confinati nel Dockerfile se non assegnati con ENV (vedi Dockerfile)
curl -XGET http://localhost:8081/not_greet
# 3) Ritorna $SIMPLE_ENV -> "Yes, I'm here!" passato con -e alla run
curl -XGET http://localhost:8081/getenv/SIMPLE_ENV

# Loggare lo std output del container (se non si è rimasti appesi senza omettendo -d)
# Qualche opzione di log:
# -f rimane appeso sul log (come farebbe il comando tail su un file). Esci dal log con CTRL+C
# --since <param> (es: 10m) permette di mostrare il log a partire da 10 minuti prima
docker logs -f greeting

# Entrare nel container da terminale
# Qualche opzione di exec:
# -it, -i -> mantiene aperto lo std input, -t alloca un tty (una specie di terminale)
# sh è il comando che viene eseguito nel container (si può usare anche bash se presente nel container)
# sh è l'interprete che lanciato nel tty ci permette di "entrare" nel container
docker exec -it greeting sh
# Ora possiamo vedere che l ARG, anche se non passato ad un ENV, è stato stampato correttamente nel file text.txt
cat text.txt


# Run del container in un volume
# Con questo metodo è possibile sviluppare direttamente dentro al container
docker build --build-arg WHO_TO_GREET="World" --build-arg WHO_TO_NOT_GREET="Moon" -f Dockerfile.debug -t greetings_debug .
docker run --rm --name greeting-debug -v "$(pwd)/:/usr/src/app" -e SIMPLE_ENV="Yes, I'm here\!" -p 8082:8080 -p 9999:9999 greetings_debug
# Il container usa nodemon per lanciare l'applicazione così quando i sorgenti vengono modificati nodemon lo rilancia automaticamente
# Inoltre il debugger viene lanciato sulla porta 9999 e con vscode (vedi file .vscode/launch.json) possiamo fare attach del debugger

# Entrare nel container al suo avvio
docker run --rm --name busy -it busybox sh

# Cancellare una lista di immagine filtrate con grep
docker rmi $(docker images | grep none | awk '{print $3}')

# Creare un immagine da un container
docker commit <existent_container_name> <new_image_name>

# Stampare la lista delle subnet
# bridge, host e none sono le subnet di default
docker network ls

# Creare/cancellare una sottorete
docker network create <subnet_name>
docker network rm <subnet_name>

# Connettere/disconnettere un container da una sottorete
docker network connect <subnet_name> <container_name>
docker network disconnect <subnet_name> <container_name>

# Cambiare la restart policy
# Alcune sono: always, unless-stopped, on-failure:<failure_counter>
docker update --restart=on-failure:3 <container_name>

# Qualche run di database
# Postgresql
docker run -d -it --network my-subnet --name my-postgres \
  -e POSTGRES_USER=root -e POSTGRES_PASSWORD=Betacom2022 \
  -e PGDATA=/var/lib/postgresql/data/pgdata \
  -v "$(pwd)/postgres:/var/lib/postgresql/data" \
  -p 5432:5432 postgres
# Redis
docker run --name my-redis -d -p 6378:6379 redis:alpine


#### DOCKER COMPOSE

# Run con docker compose
# Dalla versione 2 si può usare docker compose, prima il comando era docker-compose
# -p indica il nome dell'applicazione
# -d opera il detach come per la docker run
# --force-recreate forza la distruzione dei container precedenti (se presenti)
# --build fa si che vengano nuovamente "buildate" le immagini
docker compose -p example up -d --force-recreate --build
# Di default viene letto il file docker-compose.yml, ma si può passare un altro file con l'opzione -f
# In questo caso passiamo una configurazion per il debug
docker compose -f docker-compose.debug.yml -p example up -d --force-recreate --build

# Utilizzando nginx come reverse proxy è possibile scalare le repliche del node-server
# Senza nginx non si potrebbe fare perchè la seconda replica tenterenne il bind della stessa porta sulla macchina host
# Il balancing viene fatto direttamente dal docker engine
docker compose -p example up -d --scale node-server=2

# Entrando nel container postgres
docker exec -it example-pg-server-1 bash
# Installa il comando ping 
apt update && apt install -y iputils-ping
# Provando a fare il ping più volte su node-server si vede risponde sempre un indirizzo ip diverso
ping node-server

# Testare il server
# 1) Ritorna il contenuto della tabella users creata e riepita con il file ./migrations/init-pg.sql
curl -XGET http://localhost:8083/db_users

# Fermare tutti i container del docker compose
docker compose -p example stop

# Cancellare tutti i container in stop del docker compose
# -s i container vengono anche fermati, così da poter essere cancellati
# -f la cli non chiede conferma dell'operazione
# -v vengono cancellati anche tutti i volumi associati
docker compose -p example rm -s -v -f

# Multistage build
docker build --build-arg WHO_TO_GREET="World" --build-arg WHO_TO_NOT_GREET="Moon" -f Dockerfile.multistage -t greetings_multistage .
docker run --rm --name greeting-multistage -e SIMPLE_ENV="Yes, I'm here\!" -p 8084:8080 greetings_multistage
curl -XPOST -H "Content-Type: application/json" -d '{"executable": "./mylib"}' http://localhost:8084/exec_process