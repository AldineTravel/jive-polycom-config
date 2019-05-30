#!/bin/bash

echo $0
PASSWORD=$(echo -n "Polycom:$1" | base64)
echo $PASSWORD

for ip in 192.168.{85..86}.{248..249}
do
    echo " ============== "
    echo "${ip}"
    MAC_ADDR=$(curl -s "https://${ip}/home.htm" -H "Referer: https://${ip}/" -H "Cookie: Authorization=Basic ${PASSWORD}" --insecure | grep "64:16:" | tr -d " :" | tr '[:upper:]' '[:lower:]')
    PROV_URL=$(curl -s "https://${ip}/provConf.htm" -H "Referer: https://${ip}/" -H "Cookie: Authorization=Basic ${PASSWORD}" --insecure | grep rtcprov | grep -oP '(?<=value=").*?(?=" paramName)')
    echo -e "\t${MAC_ADDR}\n\t${PROV_URL}"
    CONF_URL="https://${PROV_URL}/${MAC_ADDR}-web.cfg"
    echo -e "\t\t${CONF_URL}"
    
    [[ -z "${MAC_ADDR}" ]] && continue

    echo "* Applying settings:"
    NEW_FILE="${MAC_ADDR}-web.cfg"
    cp "_MASTER-WEB.cfg" ${NEW_FILE}
    curl -A "User-Agent: Polycom/6.0.0.0 PolycomVVX-VVX_501-UA/6.0.0.0" ${CONF_URL} --upload-file ${NEW_FILE}
    echo -e "** Done **\n"
done

