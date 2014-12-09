#!/bin/bash
zbStartUpLog=/usr/local/silo/agent/zbStartUp.log
zbServerLog=/usr/local/silo/agent/zbServer.log

/usr/local/silo/agent/bin/setuplprfcape_reva1.sh

#check ttyACM0-4
zbCdcDev=/dev/ttyACM
zbDevCdcIdx=0
for zbDevCdcIdx in 0 1 2 3 4
do
	echo "getFwModel from $zbCdcDev$zbDevCdcIdx" >> $zbStartUpLog
	modelId="$(/usr/local/silo/agent/bin/zbFwStart.linux.arm.bin $zbCdcDev$zbDevCdcIdx)"

	if [[ "$modelId" =~ "Model ID" ]]; then
		zbDev=$zbCdcDev$zbDevCdcIdx
		echo "Found device: " $zbDev >> $zbStartUpLog
		echo "modelId: " $modelId >> $zbStartUpLog
		break
	fi
done

if [[ -z "$zbDev" ]]; then
	zbttyDev=/dev/ttyO4
        echo "getFwModel from $zbttyDev" >> $zbStartUpLog
        modelId="$(/usr/local/silo/agent/bin/zbFwStart.linux.arm.bin $zbttyDev)"

        if [[ "$modelId" =~ "Model ID" ]]; then
                zbDev=$zbttyDev
                echo "Found device: " $zbDev >> $zbStartUpLog
                echo "modelId: " $modelId >> $zbStartUpLog
        fi
fi


if [[ $modelId =~ "ZBGW" ]] ; then
	echo "Starting zbGateway with $zbDev" >> $zbStartUpLog
	/usr/local/silo/agent/bin/zbGateway.linux.arm.bin $zbDev > $zbServerLog 2>&1
else
	if [[ $modelId =~ "TI SampleBridge" ]] ; then
        	echo "Starting zllGateway with $zbDev" >> $zbStartUpLog
        	/usr/local/silo/agent/bin/zllGateway.linux.arm.bin $zbDev > $zbServerLog 2>&1
	else
                echo "Unknown zb device" >> $zbStartUpLog
	fi
fi
