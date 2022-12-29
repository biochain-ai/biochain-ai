## Comandi per avviare la blockchain

Per avviare tutta le rete verrà utilizzato un tool chiamato __minifabric__.
Questo tool permette di semplificare l'utilizzo e l'esecuzione dei comandi 
all'interno della blockchain.

__Minifabric__ è sostanzialmente uno script che viene invocato tramite `minifab`.

Con `minifab -h` è possibile vedere tutti i possibili comandi.

E' possibile trovare la documentazione del tool a questo link: https://github.com/hyperledger-labs/minifabric/blob/main/docs/README.md
E' presente anche una piccola guida per l'installazione. Se i comandi vengono 
eseguiti sul server, il tool è già presente.

## Avviare la blockchain
- Lanciare docker (se non dovesse essere già attivo)
- Controllare che lo script di _minifabric_ sia presente eseguire 

    `minifab -h`

    (dovrebbe restituire la schermata di help)

- In caso contrario provare con
    
    `sudo minifab -h`

- In caso contrario, seguire la procedura per il download presente nella documentazione
- Creare un cartella temporanea (es. `temp`) che conterra tutti i file relativi all'esecuzione
- Copiare dalla cartella `home/adiana/biochain-ai/` il file `spec.yaml` all'interno
della cartella temporanea precedentemente creata. (Questo file è un file di configurazione per la rete che viene letto in 
automatico dallo script e che permette di personalizzare la rete. E' possibile 
comunque eseguire una rete blockchain standard omettendo quel file)
- Spostarsi dentro la cartella temporanea
- Per avviare la rete, eseguire il comando
    
     `minifab up -o parma.com`
     
    (eventualmente aggiungere `sudo`)

    (Questo comando legge il file di configurazione `spec.yaml` e genera la rete corrispondente. Il flag `-o parma.com` è necessario per questa configurazione perchè definisce l'organizzazione che eseguire le operazioni per cui si necessità di una organizzazione. Nel caso in cui si voglia lanciare la rete di default e cioè senza utilizzare il file `spec.yaml`, è possibile omettere questo flag e utilizzare l'organizzazione di default (il nome _parma.com_ è un nome che dipende solo dalla configurazione ma è solo un nome simbolico)
- Al termine, dopo alcuni minuti, è possibile visualizzare i container che vengono creati tramite il comando

     `docker ps`. 

- Tramite il comando

     `minifab explorerup`
    
     è possibile avviare un explorer che, tramite **browser**, permette di visualizzare una serie di statistiche relative alla rete creata
- Per smantellare la rete, sempre dalla cartella creata in precedenza, eseguire
     
     `minifab down`
     
    (Permette di "spegnere" tutti i container mantenendo però tutti i file creati in modo da poter eseguire nuovamente la rete in un secondo momento)
- Per eliminare la rete, dopo avere eseguito `minifab down`, eseguire

     `minifab cleanup`

    (Questo permette di eliminare tutti i file creati dall'esecuzione che vengono salvati all'interno di una cartella chiamata `vars` creata e gestita dallo script)

E' possibile verificare in ogni momento, tramite il comando `docker ps` l'esecuzione dei container della rete

## Installare chaincode custom

Per installare chaincode custom che utilizza i transient data è necessario eseguire le seguenti operazioni:

- Eseguire la rete blockchain come descritto sopra
- Copiare il codice dello smart contract dentro la cartella `vars/chaincode/` che viene creata dopo l'inizializzazrione della rete
- Installare lo smart contract con il seguente comando

	`minifab install -n <nomeSmartContract> -r true`

- Modificare il file `<nomeSmartContract>_collection_config.json` con i nomi corretti per le collezioni dei dati privati
- Eseguire

	`minifab approve,commit,initialize .p '' `

Al termine di queste operazioni lo smart contract sarà pronto per essere eseguito

## Eseguire i metodi dello smart contract

Per eseguire i metodi sullo smart contract è necessario utilizzare `minifab invoke` specificando il nome del metodo che si vuole invocare, i parametri, gli eventuali transient data ed eventualmente l'organizzazione che sta eseguendo il metodo

Il seguente comando permette di create una variabile, che verrà poi passata al comando di invocazione, contentente i dati nel formato corretto per i dati transienti

	` DATA=$( echo '{"name":"PrimoDato","description":"descrizione del primo dato","data":"qwertyuioplkjhgfdsazxcvbnm"}' | base64 | tr -d \\n )`

Verrebbe poi sfruttata all'interno del comando nel seguente modo

	 ` minifab invoke -p '"insertData"' -t '{"data":"'$DATA'"}' -o parma.com`

Dove 'insertData' è il nome del metodo che vogliamo invocare, '-t' permette di stabilire i dati transienti che vogliamo inviare. E' necessario speficiare il nome del parametro nella mappa dei dati transienti.
'-o' permette di sbailire qual è l'organizzazione che sta eseguendo il metodo


