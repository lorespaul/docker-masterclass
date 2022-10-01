# https://hub.docker.com/_/node
FROM node:16-alpine

# Solo una label dove mettere le referenze del creatore/manutentore del file
LABEL maintainer="l.daneo@betacom.it"

# Un ARG è un argomento che viene passato al docker file, e non esiste nel contesto del container
# Non si posso usare ARG nel CMD/ENTRYPOINT!
ARG WHO_TO_GREET
ARG WHO_TO_NOT_GREET
# Un ENV è una variabile d'ambiente accessibile anche dal container
ENV WHO_TO_GREET=$WHO_TO_GREET


# Imposta la home dell'immagine e del futuro container
WORKDIR /usr/src/app

# Copia il contenuto della directory corrente (primo parametro) dentro alla home dell'immagine (secondo parametro)
COPY . ./

# Dichiara la porta su cui sarà raggiungibile il server
# Non fa il port forwarding!
EXPOSE 8080

# Esegue un comando nel contesto dell'immagine
# Ogni RUN crea un nuovo layer, quindi si cerca di eseguire tutti i comandi all'interno di meno RUN possibili
# Si usa il \ per fare l'escape del carattere break line
RUN npm install && \
    echo "I will greet $WHO_TO_GREET..." && \
    echo "...and I will not greet $WHO_TO_NOT_GREET" && \
    echo "I will greet $WHO_TO_GREET..." > text.txt && \
    echo "...and I will not greet $WHO_TO_NOT_GREET" >> text.txt

# Dichiara il comando che verrà eseguito alla partenza del container
# In questo caso viene usato node, ma si poteva usare anche npm start
ENTRYPOINT [ "node" ]
# Si poteva anche eseguire ENTRYPOINT [ "node", "server.js" ] oppure CMD [ "node", "server.js" ]
# CMD ci da la possibiltà di passare degli argomenti da concatenare a CMD alla run del container
CMD [ "server.js" ]
