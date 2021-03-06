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
#2>&1 |tee -a $logfile
############################################################################################################################################################################
############################################################################################################################################################################
#Definizione variabili: ####################################################################################################################################################
############################################################################################################################################################################
############################################################################################################################################################################
#conta=2							# inizializzo variabile a 2 - non toccare
. mountManager.config

############################################################################################################################################################################
############################################################################################################################################################################
#Definizione Funzioni: #####################################################################################################################################################
############################################################################################################################################################################
############################################################################################################################################################################

. functions.sh

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
echo "###  `$timestamp` - $scriptname log file"
echo "###  Lo script monta tutte le partizioni indicate"
echo "###  Eseguito da $USER - Home:$HOME | in `pwd`"
echo "###  file di log $fileLogName - in $DestLogPath"
echo "############################################################################"
echo "############################################################################")2>&1 |tee -a $logfile
#Logging session:
printf "\n\n\n" 
((echo "`$timestamp`: Creo File - $fileLogName - in $DestLogPath" && echo "`$timestamp`: inizio script") || (exit 99 && echo "`$timestamp`: impossibile creare file di log!!"))2>&1 |tee -a $logfile

# Verifico esistenza pacchetti neccessari:
pkgeExistence cifs-utils
pkgeExistence smbclient

#Mostro Menu:
showMenu

endScript 0


# Arriverà con la prossima versione:
#chiamo funzione arrayMout, per montare dischi
#arrayMount $*
#endScript $?

#fine script
