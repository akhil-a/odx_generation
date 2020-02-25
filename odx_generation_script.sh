#!/bin/bash

echo "******************************"
echo "*Script for Creating ODX file*"
echo "******************************"
AOSP_DIR=$(pwd)
Bin=Bin_DIR
Date="$(date "+%Y-%m-%d")T$(date "+%T")"
if [ ! -d ${AOSP_DIR} ]; then
  echo "Source not found"
  exit
fi

#copy demo odx file to here
SW_VERSION=$(echo "$(sed -n '/RSE_SW_VERSION/p' ${AOSP_DIR}/Inputs/sw_update_info.xml)" | awk -F"[> <]" '{print $3}')
SW_PART_NO=$(echo "$(sed -n '/SW_PART_NO/p' ${AOSP_DIR}/Inputs/sw_update_info.xml)" | awk -F"[> <]" '{print $3}')
UPDATE_PACKAGE=${SW_PART_NO}_${SW_VERSION}.bin
cp -r ota_package_sl.bin ${UPDATE_PACKAGE}
VARIENT=$(echo ${SW_PART_NO} | cut -b 1-3)
REVISION_LABEL=$(echo ${SW_VERSION} | cut -b 1-2).$(echo ${SW_VERSION} | cut -b 3-4).$(echo ${SW_VERSION} | cut -b 5-6)
echo $VARIENT
E_STAND_VALUE=E229_0
if [ ${VARIENT} == 167 ];then
	NTG_VALUE=NTG6L
	RSE_VALUE=RSE6L
	RSE_R_VALUE=RSE6R
else
	NTG_VALUE=NTG7L
	RSE_VALUE=RSE7L
	RSE_R_VALUE=RSE7R
fi
NAME=FW_${NTG_VALUE}_${VARIENT}_${RSE_VALUE}_${E_STAND_VALUE}_CODE

ODX_FILE=${NAME}_${SW_PART_NO}_${SW_VERSION}.odx-f
echo "ODX file name:${ODX_FILE}"
echo "copying demo odx file and renaming odx file"
cp -r ${AOSP_DIR}/Inputs/odx.xml ${ODX_FILE}

sed -i "s/RSE6L/${RSE_VALUE}/g" ${ODX_FILE}
sed -i "s/RSE6R/${RSE_R_VALUE}/g" ${ODX_FILE}

REPLACE_NAME=$(echo "$(sed -n '/SHORT-NAME/p' ${ODX_FILE} | head -1)" | awk -F"[><]" '{print $3}')
REPLACE_SW_VERSION=$(echo "$(sed -n '/IDENT-VALUE TYPE="A_ASCIISTRING/p' ${ODX_FILE})" | awk -F"[><]" '{print $3}')
REPLACE_PARTNUMBER=$(echo "$(sed -n '/PARTNUMBER/p' ${ODX_FILE})" | awk -F"[><]" '{print $3}')
REPLACE_PACKAGE_NAME=$(echo "$(sed -n '/DATAFILE LATEBOUND-DATAFILE/p' ${ODX_FILE})" | awk -F"[><]" '{print $3}')
REPLACE_END_ADDRESS=$(echo "$(sed -n '/END-ADDRESS/p' ${ODX_FILE})" | awk -F"[><]" '{print $3}')
REPLACE_CRC_VALUE=$(echo "$(sed -n '/FW-CHECKSUM/p' ${ODX_FILE})" | awk -F"[><]" '{print $3}')
REPLACE_SIGNATURE=$(echo "$(sed -n '/FW-SIGNATURE/p' ${ODX_FILE})" | awk -F"[><]" '{print $3}')
REPLACE_REVISION_LABEL=$(echo "$(sed -n '/REVISION-LABEL/p' ${ODX_FILE})" | awk -F"[><]" '{print $3}')
#Find End-Address
END_ADDRESS=$(printf '%x\n' $(expr $(du -b ${UPDATE_PACKAGE} | cut -f1) - 1))
count=$(echo -n $END_ADDRESS | wc -c)
while [ $count -ne 8 ]
do
        END_ADDRESS=0$END_ADDRESS
        count=`expr $count + 1`
done
echo "End Address :${END_ADDRESS}"
#Find CRC value
CRC_VALUE=$(crc32 ${UPDATE_PACKAGE})
echo "crc value :${CRC_VALUE}"
echo "*****Values to Replace*****"
echo "Name              : $REPLACE_NAME"
echo "SW Version        : $REPLACE_SW_VERSION"
echo "PARTNUMBER        : $REPLACE_PARTNUMBER"
echo "Revision Label	: $REPLACE_REVISION_LABEL"
echo "Package Name      : $REPLACE_PACKAGE_NAME"
echo "End Address       : $REPLACE_END_ADDRESS"
echo "CRC Value         : $REPLACE_CRC_VALUE "

echo "*****New Values*****"
echo "Name              : $NAME"
echo "SW Version        : $SW_VERSION"
echo "PARTNUMBER        : ${SW_PART_NO}_001_${SW_VERSION}"
echo "Revision Label	: $REVISION_LABEL"
echo "Package Name      : ${SW_PART_NO}_${SW_VERSION}.bin"
echo "End Address       : $END_ADDRESS"
echo "CRC Value         : $CRC_VALUE "

echo "Replacing Date"
sed -i "/DATE/c\         <DATE>${Date}<\/DATE>" ${ODX_FILE}
echo "Replacing Name"
sed -i "s/${REPLACE_NAME}/${NAME}/g" ${ODX_FILE}
echo "Replacing Part number"
sed -i "s/${REPLACE_PARTNUMBER}/${SW_PART_NO}_001_${SW_VERSION}/g" ${ODX_FILE}
echo "Replacing package Name "
sed -i "s/${REPLACE_PACKAGE_NAME}/${SW_PART_NO}_${SW_VERSION}.bin/g" ${ODX_FILE}
echo "Replacing SW Version"
sed -i "s/${REPLACE_SW_VERSION}/${SW_VERSION}/g" ${ODX_FILE}
echo "Replacing End Address"
sed -i "s/${REPLACE_END_ADDRESS}/${END_ADDRESS}/g" ${ODX_FILE}
echo "Replacing CRC Value"
sed -i "s/${REPLACE_CRC_VALUE}/${CRC_VALUE}/g" ${ODX_FILE}
echo "Replaceing Revision Label"
sed -i "s/${REPLACE_REVISION_LABEL}/${REVISION_LABEL}/g" ${ODX_FILE}
echo "calculating signature"
SIGNATURE=$(${AOSP_DIR}/Inputs/signature_calc . | tail -1)
echo "Signature:${SIGNATURE}"
echo "Replacing Signature"
sed -i "s/${REPLACE_SIGNATURE}/${SIGNATURE}/g" ${ODX_FILE}
if [ ! -d SWDL_OTA_Update_Package ]; then
	        mkdir SWDL_OTA_Update_Package
	fi
mv ${ODX_FILE} SWDL_OTA_Update_Package
mv ${SW_PART_NO}_${SW_VERSION}.bin SWDL_OTA_Update_Package

echo "************Script complete***************"
