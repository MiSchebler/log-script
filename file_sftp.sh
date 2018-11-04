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
s_path=/home/pi/scripts/sftp
s_tempdir=$s_path/tmp
s_confdir=$s_path/conf 
s_logdir=$s_path/log 
s_log=$s_logdir/$s_name-$(date +%Y%m%d).log 
s_pid=$s_tempdir/$s_name.pid 

### FUNCTION ###
pars_parameter () {
    VAR1=`echo $1 | cut -d ";" -f1`
    VAR2=`echo $1 | cut -d ";" -f2`
    VAR3=`echo $1 | cut -d ";" -f3`
    echo $VAR1
    echo $VAR2
    echo $VAR3
}

### SCRIPT ###
echo `date` "------ Script Started -----">> $s_log
echo $$ > $s_pid
echo `date` "------ PID File created. $s_pid " >> $s_log
TEMP=`mktemp -p $s_tempdir`
echo `date` "------ Temp File created. $TEMP" >> $s_log
grep -v '^#' $s_confdir/$s_name.conf | grep -v ^$ > $TEMP
echo `date` "------ Temp File fill with parameter. " >> $s_log
while read VAR
do
    echo "$VAR"
    pars_parameter $VAR
done < $TEMP
rm $TEMP
rm $s_pid
echo `date` "------ Script Stop -----">> $s_log
exit 0