#!/bin/bash
flowName=$1
env="prd"
logdir="/srv/data/scripts/ConsCom/ConsCom_log"
mkdir -p $logdir
`rm /srv/data/scripts/ConsCom/mail_file.txt`
`echo " We have not received Daily file. As per the business logic, we have processed the Dummy File & processed the job. Path: /Suppliers/ConCom/AstuteProd ----   " > /srv/data/scripts/ConsCom/mail_file.txt`
while IFS="," read -r imNames Supplierdir fileNames
do
        echo "IM Name: ${imNames}"
        echo "Supplier Directory: ${Supplierdir}"
        echo "File Pattern: ${fileNames}"
        sh /srv/data/scripts/ConsCom/dotdone_internal_ConsCom.sh ${Supplierdir} $imNames ${fileNames} ${env}
        lineCount=`cat ${imNames}_files.out | wc -l`
        if [ $lineCount -lt 1 ]; then
                echo " ${imNames} : ${fileNames} :: " >> /srv/data/scripts/ConsCom/mail_file.txt
                echo "${imNames} - No New files received" >> /srv/data/scripts/ConsCom/logfile-$flowName.txt
                #lastReceived=`cat ${imNames}_done.out | tail -1`
                echo "Removing  Dot Done  for ${imNames} as no new file found."
                hadoop fs -rm -skipTrash adl://dehdatalakestore.azuredatalakestore.net:443/iip/${env}/Adl_Dot_Done_Dir/${imNames}/${imNames}_${fileNames}Dummy.txt.done
                echo "No New File Found for IM,${imNames},$(date)" >>${logdir}/${imNames}_File_Processed.log
#*******************************************************************************************************************************

        elif [ $lineCount -gt 1 ]; then
                echo "Multiple files received.Job failed." | mail -s "Consumer Complaint Daily File Status-Multiple file received"  HERSHEY_IIP_DevOps@infosys.com SKeerthikumar@hersheys.com Conscom_Notification@hersheys.com
                exit 1
        fi
#*******************************************************************************************************************************
#rm /home/iip/${imNames}_files.out
#rm /home/iip/${imName}_done.out
#rm /home/iip/${imName}_supp.out

done < "/srv/data/scripts/jobConfig/$flowName"

filecount=`cat /srv/data/scripts/ConsCom/mail_file.txt | wc -l`

if [ $filecount -gt 1 ]; then
mail -s "Consumer Complaint Daily File Status" HERSHEY_IIP_DevOps@infosys.com SKeerthikumar@hersheys.com Conscom_Notification@hersheys.com < /srv/data/scripts/ConsCom/mail_file.txt
# " HERSHEY_IIP_DevOps@infosys.com SKeerthikumar@hersheys.com < /srv/data/scripts/s4_logfiles/logfile-$flowName.txt"
fi
>/srv/data/scripts/ConsCom/logfile-$flowName.txt
