#/bin/sh

TOKEN=$(cat ~/usr/misc/homeassistant)

request() {
    curl -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{\"entity_id\": \"$1\"}" "http://192.168.178.3:8123/api/services/switch/turn_$2" &> /dev/null
}

DEVICE=$(echo $1 | tr ‘[:upper:]’ ‘[:lower:]’)

case "$DEVICE" in
    l*) SWITCH="switch.office_light_switch_0" ;;
    o*) SWITCH="switch.plusplugs_office_switch_0" ;;
    w*) SWITCH="switch.shellyplusplugs_e465b8b2ea64_switch_0" ;;
    1)
        request "switch.office_light_switch_0" on
        request "switch.plusplugs_office_switch_0" on
        request "switch.shellyplusplugs_e465b8b2ea64_switch_0" on
        exit 1
        ;;
    0)
        request "switch.office_light_switch_0" off
        request "switch.plusplugs_office_switch_0" off
        exit 1
        ;;
esac

case "$2" in
    on|1) STATUS="on" ;;
    off|0) STATUS="off" ;;
esac

echo "Turning" "$SWITCH" to "$STATUS"

request "$SWITCH" "$STATUS"
