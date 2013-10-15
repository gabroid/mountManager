#!/bin/bash
#funzione verifica pacchetti:
function pkgeExistence(){
if dpkg-query -Wf'${db:Status-abbrev}' $1 | grep -q '^i'; 
	then
	    (echo "`$timestamp`: [$1] non verrà installato, è già presente nel sistema")2>&1 |tee -a $logfile
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
echo "------ Check vars -------------------"
echo "SourceIP..........: $SourceIP"
echo "SourceSubDir......: $SourceSubDir"
echo "DestPath..........: $DestPath"
echo "timestamp.........: `$timestamp`"
echo "DestLogPath.......: $DestLogPath"
echo "logfile...........: $logfile"
echo "scriptname........: $scriptname"
echo "fileLogName.......: $fileLogName"
echo '${what[*]}........: '${what[*]}''
echo '${what[$x]}.......: '${what[$x]}''
#echo '${listMount[$x]}..: '${listMount[$x]}''
echo "x.................: $x"
echo "conta.............: $conta"
echo "optionNumbers.....:"$optionNumbers
echo "rc................: $rc"
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

#funzione di smontaggio:
function smonta(){
#Verifico esistenza cartelle ed eventualmente le creo
checkDirs $DestPath			#cartella di destinazione
checkDirs $DestLogPath		#Cartella destinazione logs
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

#Crea dinamicamente il menu
function showMenu(){
#cancello il file menu temporaneo precedentemente creato
(rm $filemenu 2>&1 |tee -a $logfile && echo "`$timestamp`: cancellato file temporaneo $filemenu" 2>&1 |tee -a $logfile) || echo "`$timestamp`: errore cancellazione file temporaneo $filemenu"2>&1 |tee -a $logfile

conta=2

printf "#######################################\n"
printf "# Scegli una Opzione                  #\n"
printf "# 0 -> annulla script                 #\n"
printf "# 1 -> Smonta tutto!                  #\n"

# definisco array e disegno menu dinamicamente
what=($listMount)
printf "# $conta -> monto: ${what[*]}  \n"
optionNumbers=$((${#what[*]}+$conta))						# quante opzioni per il menu comprese 0 annulla script e 1 smonta tutto
conta=$(($conta+1))
for wtf in ${what[*]}
	do 
		printf "# $conta -> monto: $wtf  \n"
		conta=$(($conta+1))	
	done
conta=2
echo "# inserisci un numero: ################"
read option
echo "# Hai scelto $option                  #"
#echo "OPTIONUMBERS è $optionNumbers"
if [ $option -le $optionNumbers -a $option -ge 0 ];
	then
		echo "case $option in" >> $filemenu
		
		(echo "0)")>>$filemenu
		(echo 'echo "# Scelta opzione '$option' -> annulla script                 "')>>$filemenu
		(echo 'echo "'`$timestamp`': Scelta opzione '$option' Script Annullato">>'$logfile'')>>$filemenu
		(echo 'endScript 1')>>$filemenu
		(echo ";;")>>$filemenu
		(echo "1)")>>$filemenu
		(echo 'echo "# Scelta opzione '$option' -> smonta tutto                   "')>>$filemenu
		(echo 'echo "'`$timestamp`': Scelta opzione '$option' Smontare tutto">>'$logfile'')>>$filemenu
		(echo 'smonta')>>$filemenu
		(echo ";;")>>$filemenu
		(echo "$conta)")>>$filemenu
		(echo 'echo "# Scelta opzione '$option' -> Monta '${what[$*]}'"')>>$filemenu
		(echo 'echo "'`$timestamp`': Scelta opzione '$conta' (Montare '${what[$*]}')">>'$logfile'')>>$filemenu
		(echo 'arrayMount '${what[*]}'')>>$filemenu
		(echo ";;")>>$filemenu
		conta=$(($conta+1))
		x=0
		#debug 289
			while [ $conta -le $optionNumbers ];
					do 
						(echo "$conta)")>>$filemenu
						(echo 'echo "# Scelta opzione '$option' -> Monta '${what[$x]}'"')>>$filemenu
						(echo 'echo "'`$timestamp`': Scelta opzione '$conta' (Montare '${what[$x]}')">>'$logfile'')>>$filemenu
						(echo 'arrayMount '${what[$x]}'')>>$filemenu
						(echo ";;")>>$filemenu
						conta=$(($conta+1)) 
						x=$(($x+1))
						#debug 299
					done
		(echo "esac")>>$filemenu
		. $filemenu
	else
		printf "########## /!\ ATTENZIONE /!\ #########\n"
		printf "# Inserito valore non corretto $option       \n"
		printf "# ricarico Menù                       #\n"	
		printf "#######################################\n"
		echo "`$timestamp`: inserito valore non corretto ->$option<-"
	exit 11
fi

}


function showMenu_OLD(){
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

case $option in
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

# Crea menu dinamicamente in base a quanto si vuole montare
function dinMenu(){
what=($*)
printf "# $conta -> monto: ${what[*]}  \n"
conta=$(($conta+1))
for wtf in ${what[*]}
	do 
		printf "# $conta -> monto: $wtf  \n"
		conta=$(($conta+1))	
	done
}
