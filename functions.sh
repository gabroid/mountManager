#!/bin/bash
#funzione verifica pacchetti:
function pkgeExistence(){
if dpkg-query -Wf'${db:Status-abbrev}' $1 | grep -q '^i'; 
	then
	    (echo "`$timestamp` : [$1] non verrà installato, è già presente nel sistema")2>&1 |tee -a $logfile
	else
		(echo "`$timestamp`:  $1 -> non è presente, perchè questo script funzioni è necessario installarlo, vuoi farlo Y(yes) N(No)?")2>&1 |tee -a $logfile
		read choose
	if [ $choose = "Y" -o $choose = "y" ];
		then
			(echo ""
			echo ""
			echo ""
			echo "`$timestamp` : [$1] -> INSTALLO $1:"
			echo "")2>&1 |tee -a $logfile
			(sudo apt-get -V -y install $1 && echo"`$timestamp`:  $1 -> installazione riuscita" || echo "`$timestamp`:  $1 -> Errore installazione $1")2>&1 |tee -a $logfile
		elif [ $choose = "N" -o $choose = "n" ];
			then
				(echo "`$timestamp`:  $1 -> $USER ha scelto di non installare $1($choose). Lo script potrebbe incorrere in problemi imprevisti anche gravi")2>&1 |tee -a $logfile
		else
			(echo "`$timestamp`:  $1 -> Errore  inatteso durante scelta installazione $1")2>&1 |tee -a $logfile
	fi

fi
choose=null
}

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
((echo "`$timestamp`: Monto disco $SourceSubDir";sudo mount -t cifs //$SourceIP/$SourceSubDir $DestPath/$SourceSubDir/ -o user=$USER,pass=$password,rw,hard,nosetuids,noperm,sec=ntlm) && (echo "`$timestamp`: $SourceSubDir montato su $DestPath/$SourceSubDir corretamente" || echo "`$timestamp`: Errore montaggio $SourceSubDir"))2>&1 |tee -a $logfile
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
echo "timestamp......: $$timestamp"
echo "DestLogPath....: $DestLogPath"
echo "logfile........: $logfile"
echo "scriptname.....: $scriptname"
echo "fileLogName....: $fileLogName"
echo "rc.............: $rc"
echo "------------------------------------")2>&1 |tee -a $logfile
fi
}

#funzione di fine script
function endScript(){
#Fine script scrivo su log ed esco
(
echo "`$timestamp`: Script Terminato"
echo ""
echo "RC script ->$1<-"
echo "      __________END__________"
echo "")2>&1 |tee -a $logfile
debug $?

exit $1
}

#funzione per opzioni menu
function menuOpzioni(){
scelta=$1
case $scelta in
0)
	printf "# Scelta opzione $option -> Smonta tutto                   #\n"	
	echo "`$timestamp`: Scelta opzione $option (Smontare tutto)">>$logfile
	smonta
;;
1)
	printf "# Scelta opzione $option -> annulla script                 #\n"
	echo "`$timestamp`: Scelta opzione $option (Script Annullato!)">>$logfile
	endScript 1
;;
2)
	printf "# Scelta opzione $option -> Monta DISKA DISKB DISKC DISKD  #\n"
	echo "`$timestamp`: Scelta opzione $option (Montare DISKA DISKB DISKC DISKD)">>$logfile
	arrayMount DISKA DISKB DISKC DISKD
;;
3)
	printf "# Scelta opzione $option -> Monta solo DISKA               #\n"
	echo "`$timestamp`: Scelta opzione $option (Montare DISKA)">>$logfile
	arrayMount DISKA
;;
4)
	printf "# Scelta opzione $option -> Monta solo DISKB               #\n"
	echo "`$timestamp`: Scelta opzione $option (Montare DISKB)">>$logfile
	arrayMount DISKB
;;
5)
	printf "# Scelta opzione $option -> Monta solo DISKC               #\n"	
	echo "`$timestamp`: Scelta opzione $option (Montare DISKC)">>$logfile
	arrayMount DISKC
;;
6)
	printf "# Scelta opzione $option -> Monta solo DISKD               #\n"	
	echo "`$timestamp`: Scelta opzione $option (Montare DISKD)">>$logfile
	arrayMount DISKD
;;
esac
}

function smonta(){
#Verifico esistenza cartelle ed eventualmente le creo
checkDirs $DestPath			#cartella di destinazione
checkDirs $DestLogPath		#Cartella destinazione logs

#Smonto tutto
#(echo ""
#echo ""
#echo ""
#echo ""
#echo "############################################################################"
#echo "############################################################################"
#echo "###  $$timestamp - $scriptname log file"
#echo "###  Lo script smonta tutte le partizioni"
#echo "###  Eseguito da $USER - Home:$HOME | in `pwd`"
#echo "###  file di log $fileLogName - in $DestLogPath"
#echo "############################################################################"
#echo "############################################################################") >>$logfile
((sudo umount -a -t cifs && echo "`$timestamp`: smonto tutto") || (echo "$$timestamp: errore smontaggio" && exit 99))2>&1 |tee -a $logfile
debug $?
echo "`$timestamp`: script finito"2>&1 |tee -a $logfile
(echo ""
echo "RC script ->$?<-"
echo "      __________END__________"
echo "")2>&1 |tee -a $logfile
debug $?
exit $?
}

function showMenu(){
#verifico che siano inseriti i parametri
	printf "#######################################\n"
	printf "# Scegli una Opzione                  #\n"
	printf "# 0 -> Smonta tutto!                  #\n"
	printf "# 1 -> annulla script                 #\n"
	printf "# 2 -> Monta DISKA DISKB DISKC DISKD  #\n"
	printf "# 3 -> Monta solo DISKA               #\n"
	printf "# 4 -> Monta solo DISKB               #\n"
	printf "# 5 -> Monta solo DISKC               #\n"
	printf "# 6 -> Monta solo DISKD               #\n"
	printf "#######################################\n"
	printf "#######################################\n"
	echo   "# inserisci un numero: ################"
	read option
if [ $option -lt "7" ] && [ $option -gt "-1" ]
	then
		menuOpzioni $option
	else
		printf "########## /!\ ATTENZIONE /!\ #########\n"
		printf "# Inserito valore non corretto $option       \n"
		printf "# ricarico Menù                       #\n"	
		printf "#######################################\n"
		echo "`$timestamp`: inserito valore non corretto ->$option<-">>$logfile
		showMenu
fi

}

# check se la directory esiste:
function checkDirs(){
directory=$1
if [ ! -d "$directory" ]; then
mkdir -p $directory
(echo "`$timestamp`: Creata cartella: $directory")2>&1 |tee -a $logfile
fi
}
