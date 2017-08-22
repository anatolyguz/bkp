#!/bin/bash




# Временная папка
TEMDIR="/tmp/bkp"
#Откуда будем бекапить
SERVER="192.168.1.38"
#Куда будем бекапить
BK_SERVER="/home/backupper/MyCloud"
LOGFILE="/home/backupper/MyCloud/backup.log"



function backupweekly {


#if [ $my_folder = "Public" ] ; then


	#Если еще нет такой папки, то создаем ее
	if [ ! -d $BK_SERVER/$my_folder/weekly ] ; then
		mkdir $BK_SERVER/$my_folder/weekly
	fi

	echo $my_folder	
	NameOfFile=$BK_SERVER/$my_folder/weekly/$(date +%y%m%d).tar.gz

	#Удаляем мета-файл
	#rm $NameOfMetaFile


	echo $NameOfFile
	tar -zcf $NameOfFile --listed-incremental=$NameOfMetaFile $TEMDIR 
	#tar
	#ls $TEMDIR
#fi


}


function backupdayly {


#if [ $my_folder = "Public" ] ; then


	#Если еще нет такой папки, то создаем ее
	if [ ! -d $BK_SERVER/$my_folder/dayly ] ; then
		mkdir $BK_SERVER/$my_folder/dayly
	fi

	echo $my_folder	
	NameOfFile=$BK_SERVER/$my_folder/dayly/$(date +%y%m%d).tar.gz

	echo $NameOfFile
	tar -zcf $NameOfFile --listed-incremental=$NameOfMetaFile $TEMDIR 
	#tar
	#ls $TEMDIR
#fi


}


function backupfolder 
{
	local my_folder=$1


#На случай ошибки предыд. копии,  размонтируем
umount $TEMDIR

# 	echo $my_folder	
 
if [ -d $TEMDIR ] ; then
	rmdir $TEMDIR
fi

mkdir $TEMDIR



#Монтирование 
mount -t nfs -O uid=1000,iocharset=utf-8 $SERVER:/nfs/$my_folder $TEMDIR

#Если еще нет такой папки, то создаем ее
if [ ! -d $BK_SERVER/$my_folder ] ; then
	mkdir $BK_SERVER/$my_folder
fi

# Имя файла для метаданных
NameOfMetaFile=$BK_SERVER/$my_folder/meta.inc

backupweekly $my_folder $NameOfMetaFile

#Размонтирование 
umount $TEMDIR

rmdir $TEMDIR

} 



echo $(date -R) " start backup" >> $LOGFILE


# Получаем список ресурсов
for param in `showmount -e   192.168.1.38` ; do
#  showmount выводит много лишнего, а надо долько ресурсы
	if [[ ! $param =~ "/" ]] ; then
			continue
	fi

	nameresurce=${param##*/}	
#  	echo $nameresurce

  	backupfolder $nameresurce
	

done

 
echo $(date -R) " finish backup" >> $LOGFILE

#IP=$(ifconfig enp2s0| sed -n '2 {s/^.*inet addr:\([0-9.]*\) .*/\1/;p}')

#notify-send $IP
