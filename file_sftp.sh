#!/bin/bash
###############
##
##  Name            :   file_sftp.sh
##  Data            :   2018-10-31
##  Version         :   0.0.1
##  Autor           :   Michael Schebler    <mischebler@web.de>
##  Changes         :   0.0.1   -   Create Skript
##  Description     :   Get Logfiles from remote Host to local filesystem.
##
###############

### CONFIG ###
s_name=`basename $0 .sh`
s_path=/home/pi/scripts/log-script
s_tempdir=$s_path/tmp
s_confdir=$s_path/conf 
s_logdir=$s_path/log 
s_log=$s_logdir/$s_name-$(date +%Y%m%d).log 
s_date=`date +%Y%m%d`                           # Datum fürs Script selber
s_pid=$$
s_err=$s_logdir/$s_name-$(date +%Y%m%d).err

### FUNCTION ###
f_software () {
    if [ whitch mysql ]
    then
        echo "MySql vorhanden"
    fi
}

f_pid () {
    if [ -e $s_tempdir/$s_name.pid ]
        then
            exit 0
    fi
    echo $s_pid > $s_tempdir/$s_name.pid
    echo `date` "------ PID File created. $s_pid " >> $s_log          # Temporäre Kontrollfunktion
}

f_logstart () {
    echo -e "\n----------------------------------------" >> $s_log 
    echo -e "\n----------------------------------------" >> $s_err
    echo -e "--- `date` --- Script startet. ---" >> $s_log
    echo -e "--- `date` --- Script startet. ---" >> $s_err
}

f_pars_parameter () {
    VAR1=`echo $1 | cut -d ";" -f1`
    VAR2=`echo $1 | cut -d ";" -f2`
    VAR3=`echo $1 | cut -d ";" -f3`
    VAR4=`echo $1 | cut -d ";" -f4`
    VAR5=`echo $1 | cut -d ";" -f5`
    VAR6=`echo $1 | cut -d ";" -f6`
}

### SCRIPT ###
f_logstart
f_pid
f_software
echo `date` "------ PID File created. $s_pid " >> $s_log
TEMP=`mktemp -p $s_tempdir`
echo `date` "------ Temp File created. $TEMP" >> $s_log
mysql -u foo2 --password=demo -P 3307 -h nas -N -D TEST -e 'SELECT CONCAT(Server,";",lgPath,";",Zweig,";",Application,";",Port,";",log_file ) FROM logs;' > $TEMP
echo `date` "------ Temp File fill with parameter. " >> $s_log
while read VAR
do
    f_pars_parameter $VAR
    echo "Server      : $VAR1"
    echo "Path        : $VAR2"
    echo "Zweig       : $VAR3"
    echo "Application : $VAR4"
    echo "Port        : $VAR5"
    echo "File Mask   : $VAR6"
    echo "============="
done < $TEMP
rm $TEMP
rm $s_tempdir/$s_name.pid
echo `date` "------ Script Stop -----">> $s_log
exit 0