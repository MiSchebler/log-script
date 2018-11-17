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
db_user=foo2
db_pw=demo
db_name=TEST
db_host=nas
db_port=3307        # Default 3306


# Variable
v_storage="/<PATH>"


### FUNCTION ###
f_software_check () {
    if ! which mysql > /dev/null 
    then
        echo "MySql nicht vorhanden" >> $s_log
        rm $s_tempdir/$s_name.pid
        exit 1
    fi
    if ! which sftp > /dev/null
    then
        echo "SFTP nicht vorhanden" >> $s_log
        rm $s_tempdir/$s_name.pid
        exit 1
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
    v_server=`echo $1 | cut -d ";" -f1`
    v_lgpath=`echo $1 | cut -d ";" -f2`
    v_zweig=`echo $1 | cut -d ";" -f3`
    v_app=`echo $1 | cut -d ";" -f4`
    v_port=`echo $1 | cut -d ";" -f5`
    v_file=`echo $1 | cut -d ";" -f6`
}

f_data_db () {
    TEMP=`mktemp -p $s_tempdir`
    echo `date` "------ Temp File created. $TEMP" >> $s_log
    mysql -u $db_user --password=$db_pw -P $db_port -h $db_host -N -D $db_name -e 'SELECT CONCAT(Server,";",lgPath,";",Zweig,";",Application,";",Port,";",log_file ) FROM logs;' > $TEMP
    echo `date` "------ Temp File fill with parameter. " >> $s_log
}

f_check_dir () {
    if [ ! $v_storage/$v_zweig ]
    then
        mkdir $v_storage/$v_zweig
    fi
    if [ ! $v_storage/$v_zweig/$v_server ]
    then
        mkdir $v_storage/$v_zweig/$v_server
    fi
    if [ ! $v_storage/$v_zweig/$v_server/$v_app ]
    then
        mkdir $v_storage/$v_zweig/$v_server/$v_app
    fi

}
### SCRIPT ###
f_logstart
f_pid
f_software_check
f_data_db
while read VAR
do
    f_pars_parameter $VAR
done < $TEMP
rm $TEMP
rm $s_tempdir/$s_name.pid
echo `date` "------ Script Stop -----">> $s_log
exit 0
