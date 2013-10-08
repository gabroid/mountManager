[mountManager] - Gabriele Foresti -> https://github.com/gabroid                      Verona, 5 Ottobre 2013 (Italy)
________
============

A bash script that give to noobs the "ability" to mount\umount windows network shares.
======================================================================================

=============== ITALIANO ===============
>Che cosa è mountManager ?
Questo script monta automaticamente le shares del server, le quali vanno impostate nel file di configurazione [mountManager.config].
E' possibile passare allo script la password o impostare in /etc/sudoers l'opzione NOPASSWD per l'utente interessato.
Verranno salvati dei log nelle cartelle impostate, registreranno tutte le informazioni più interessanti, comprese informazioni per il debug.
Per qualsiasi problema o segnalazione segnala pure via mail.

>Funziona?
- Al momento funziona solo sul mio pc, sto lavorando per renderlo universale con un file di configurazione che chiamerò [mountManager.config]
- Volendo se avessi voglia di modificare il codice lo potresti rendere usabile sul tuo pc, devi cambiare i valori delle variabili.

>ToDo:
- Creare funzione per il file di configurazione per universalizzare;
- Interfaccia grafica, in QT? Zenity? altre? Studiare e scegliere;
- Cambiare tutti i commenti del codice da italiano a inglese, una opzione nel file di configurazione permetterà di cambiare la lingua dell'out dei comandi; 

=============== ENGLISH ===============
>What is mountManager ?
This script automatically mounts the shares of the server, which should be set in the configuration file [mountManager.config].
It's possible to pass to the script the user password, or set the user permissions in /etc/sudoers with NOPASSWD option.
Logs will be saved in folders setted in configuration file, recording all information useful, including information for debugging.
For any problems or warnings jut tell me via e-mail.

>Does it Works ?  
- At the moment it works on my pc, I am just working to make it universal, using a configuration file -> [mountManager.config].
- If you have time you can use this script, but before remember to modify variables.

>ToDo:
- make the config file function, to universalize the script;
- make a GUI (graphical user interface) in QT ? Zenity? other else ? I have to study and choose...;
- translate all script comments, for output transtlation, an option in config file will give the possibility to choose the right language;
