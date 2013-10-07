#!/bin/bash
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--- Script di auto mount/umount ------------------------ V 0.1 -----------------------------------------------------------------------------------------------------------
#--- 5 Ottobre 2013 -------------------------------------------------------------------------------------------- Created by Gabriele Foresti ------------------------------
#-------------------------------------------------------------------------------------------------------------------------- crone.logan@gmail.com -------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#--- Questo script monta automaticamente le shares del server vanno impostate le preferenze nella ---------------- Licence - GPL V3 ---------------------------------------
#--- definizione delle variabili con le proprie preferenze ----------------------------------------------------------------------------------------------------------------
#--- E' possibile passare allo script la password o impostare in /etc/sudoers l'opzione NOPASSWD --------------------------------------------------------------------------
#--- per l'utente interessato. --------------------------------------------------------------------------------------------------------------------------------------------
#--- Verranno salvati dei log nelle cartelle impostate, registreranno tutte le informazioni più ---------------------------------------------------------------------------
#--- interessanti, comprese informazioni per il debug. --------------------------------------------------------------------------------------------------------------------
#--- Per qualsiasi problema o segnalazione segnala pure via mail. ---------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

############################################################################################################################################################################
############################################################################################################################################################################
#Definizione variabili: ####################################################################################################################################################
############################################################################################################################################################################
############################################################################################################################################################################

password=$1 								# passata allo script da fuori
SourceIP="192.168.1.100"					# ip dove risiede la share da montare
DestPath="$HOME/NETWORKDRIVES"				# path di destinazione
timestamp="`date +%d-%m-%Y_%T`"				# timestamp
DestLogPath="$DestPath/LOG/monta"			# destinazione dei log, non terminare la stringa con /
logfile="$DestLogPath/log_automonta.log"	# nome del file di log
scriptname="$(basename "$0")"				# nome script
fileLogSearch="log_automonta.log"			# nome del file di log generico da cercare

############################################################################################################################################################################
############################################################################################################################################################################
#Definizione Funzioni: #####################################################################################################################################################
############################################################################################################################################################################
############################################################################################################################################################################

# Funzione di mount automatica, passato allo script il nome della cartella da montare, viene creata una cartella identica in locale
# con lo stesso nome e nella destination definita nel file di configurazione.
function arrayMount() {
arr=($*)

for item in ${arr[*]}
do 
	echo "Monto:$item"
	#definisco nome disco
	SourceSubDir=$item
	#chiamo funzione di mount
	monta
done
}


#Funzione di montaggio dischi
function monta() { 
		#Monto disco da server di rete:
		checkDirs $DestPath
		checkDirs $DestLogPath
		checkDirs $DestPath/$SourceSubDir
		echo "`date +%d-%m-%Y_%T`: Monto disco $SourceSubDir">>$logfile 
		(sudo mount -t cifs //$SourceIP/$SourceSubDir $DestPath/$SourceSubDir/ -o user=$USER,pass=$password,rw,hard,nosetuids,noperm,sec=ntlm && 
		(echo "`date +%d-%m-%Y_%T`: $SourceSubDir montato su $DestPath/$SourceSubDir corretamente" || echo "`date +%d-%m-%Y_%T`: Errore montaggio $SourceSubDir">>$logfile))2>>$logfile
debug $?
}

#Funzione Debug, se rc diverso da zero lista , nel file di log, le variabili valorizzate
function debug() {
rc=$1
# -ne significa not equal
if [ "$rc" -ne "0" ] ; then 
(echo "------------------------------------"
echo "------ Check vars ------------------"
echo "SourceIP.......: $SourceIP"
echo "SourceSubDir...: $SourceSubDir"
echo "DestPath.......: $DestPath"
echo "timestamp......: $timestamp"
echo "DestLogPath....: $DestLogPath"
echo "logfile........: $logfile"
echo "scriptname.....: $scriptname"
echo "fileLogSearch..: $fileLogSearch"
echo "rc.............: $rc"
echo "------------------------------------")>>$logfile
fi
}

function endScript(){
#Fine script scrivo su log ed esco
(
echo "`date +%d-%m-%Y_%T`: Script Terminato"
echo ""
echo "RC script ->$1<-"
echo "      __________END__________"
echo "")>>$logfile
debug $?

exit $1
}

function menuOpzioni(){
scelta=$1
case $scelta in
1)
	printf "# Scelta opzione 1 -> annulla script                 #\n"
	echo "`date +%d-%m-%Y_%T`: Scelta opzione $option (Script Annullato!)">>$logfile
	endScript 1
;;
2)
	printf "# Scelta opzione 2 -> Monta DISKA DISKB DISKC DISKD  #\n"
	echo "`date +%d-%m-%Y_%T`: Scelta opzione $option (Montare DISKA DISKB DISKC DISKD)">>$logfile
	arrayMount DISKA DISKB DISKC DISKD
;;
3)
	printf "# Scelta opzione 3 -> Monta solo DISKA               #\n"
	echo "`date +%d-%m-%Y_%T`: Scelta opzione $option (Montare DISKA)">>$logfile
	arrayMount DISKA
;;
4)
	printf "# Scelta opzione 4 -> Monta solo DISKB               #\n"
	echo "`date +%d-%m-%Y_%T`: Scelta opzione $option (Montare DISKB)">>$logfile
	arrayMount DISKB
;;
5)
	printf "# Scelta opzione 5 -> Monta solo DISKC               #\n"	
	echo "`date +%d-%m-%Y_%T`: Scelta opzione $option (Montare DISKC)">>$logfile
	arrayMount DISKC
;;
6)
	printf "# Scelta opzione 6 -> Monta solo DISKD               #\n"	
	echo "`date +%d-%m-%Y_%T`: Scelta opzione $option (Montare DISKD)">>$logfile
	arrayMount DISKD
;;
7)
	printf "# Scelta opzione 7 -> Smonta tutto                   #\n"	
	echo "`date +%d-%m-%Y_%T`: Scelta opzione $option (Smontare tutto)">>$logfile
	smonta
;;
esac
}

function smonta(){
# Definisco variabili:
fileLogSearch="log_smonta_*log"				  # nome file da cercare per cancellare
DestLogPath="$DestPath/LOG/smonta"			  # path di destinazione log
logfile="$DestLogPath/log_smonta.log"          		  # genera nome file di log

#Verifico esistenza cartelle ed eventualmente le creo
checkDirs $DestPath		#cartella di destinazione
checkDirs $DestLogPath		#Cartella destinazione logs

#Smonto tutto
(
echo ""
echo ""
echo ""
echo ""
echo "############################################################################"
echo "############################################################################"
echo "###  $timestamp - $scriptname log file"
echo "###  Lo script smonta tutte le partizioni"
echo "###  Eseguito da $USER - Home:$HOME | in `pwd`"
echo "###  file di log $fileLogSearch - in $DestLogPath"
echo "############################################################################"
echo "############################################################################") >>$logfile
echo "`date +%d-%m-%Y_%T`: smonto tutto">>$logfile 
((sudo umount -a -t cifs>>$logfile)>>$logfile || (echo "$timestamp: errore smontaggio">>$logfile && exit 99))2>>$logfile
debug $?
echo "`date +%d-%m-%Y_%T`: script finito">>$logfile
(echo ""
echo "RC script ->$?<-"
echo "      __________END__________"
echo "")>>$logfile
debug $?
exit $?
}

function showMenu(){
#verifico che siano inseriti i parametri
	printf "#######################################\n"
	printf "# Scegli una Opzione                  #\n"
	printf "# 1 -> annulla script                 #\n"
	printf "# 2 -> Monta DISKA DISKB DISKC DISKD  #\n"
	printf "# 3 -> Monta solo DISKA               #\n"
	printf "# 4 -> Monta solo DISKB               #\n"
	printf "# 5 -> Monta solo DISKC               #\n"
	printf "# 6 -> Monta solo DISKD               #\n"
	printf "# 7 -> Smonta tutto!                  #\n"
	printf "#######################################\n"
	printf "#######################################\n"
	echo   "# inserisci un numero: ################"
	read option
if [ $option -lt 9 ] && [ $option -gt 0 ]
	then
		menuOpzioni $option
	else
		printf "########## /!\ ATTENZIONE /!\ #########\n"
		printf "# Inserito valore non corretto        #\n"
		printf "# ricarico Menù                       #\n"	
		printf "#######################################\n"
		echo "`date +%d-%m-%Y_%T`: inserito valore non corretto ->$option<-" >>$logfile
		showMenu
fi

}

# check se la directory esiste:
function checkDirs(){
directory=$1
if [ ! -d "$directory" ]; then
mkdir -p $directory
echo "`date +%d-%m-%Y_%T`: Creata cartella: $directory"
fi
}
############################################################################################################################################################################
############################################################################################################################################################################
# Script : #################################################################################################################################################################
############################################################################################################################################################################
############################################################################################################################################################################

#Verifico esistenza cartelle ed eventualmente le creo
checkDirs $DestPath		#cartella di destinazione
checkDirs $DestLogPath		#Cartella destinazione logs
#Creo instestazioen file di log 
#intestazione:
(
echo ""
echo ""
echo ""
echo ""
echo "############################################################################"
echo "############################################################################"
echo "###  $timestamp - $scriptname log file"
echo "###  Lo script monta tutte le partizioni indicate"
echo "###  Eseguito da $USER - Home:$HOME | in `pwd`"
echo "###  file di log $fileLogSearch - in $DestLogPath"
echo "############################################################################"
echo "############################################################################") >>$logfile
#Logging session:
(printf "\n\n\n" && echo "`date +%d-%m-%Y_%T`: Creo File - $fileLogSearch - in $DestLogPath" && echo "`date +%d-%m-%Y_%T`: inizio script">>$logfile || (exit 99 && echo "`date +%d-%m-%Y_%T`: impossibile creare file di log!!">>$logfile))2>>$logfile

showMenu

endScript 0


# Arriverà con la prossima versione:
#chiamo funzione arrayMout, per montare dischi
#arrayMount $*
#endScript $?

#fine script
