#!/usr/bin/env bash
if ! type dirname > /dev/null 2>&1; then
    echo "Not even a linux or macOS, Windoze? We don't support it. Abort."
    exit 1
fi

. "$(dirname "$0")"/../../../common/common.sh

init_with_root_or_sudo "$0"

begin_banner "batchd" "deploy finishing"

info "Need to do some application initialization, wait 10 seconds to make sure the application containers are ready."
sleep 10
batchd_IMAGE_ID=$(sudo sg docker -c "docker images"|grep -w batchd|awk '{print $3}')
if [ "X${batchd_IMAGE_ID}" != "X" ]; then
    cmdPath=$(sudo sg docker -c "docker image inspect ${batchd_IMAGE_ID}" | grep "/nix/store/" | awk -F"/" '{print "/nix/store/"$4}')
    MY_BATCHD_ROOT_PASSWORD="Passw0rd"
    sudo sed "s:host=db:host=172.17.0.1:g" < /var/batchd/config/batchd.yaml | sudo su -p -c "dd of=/var/batchd/config/batchd.admin.yaml" batchd
    info "Initializing the database schema"
    sudo sg docker -c "docker run -it --rm -v /var/batchd/config:/var/batchd/config ${batchd_IMAGE_ID} ${cmdPath}/bin/batchd-admin --config /var/batchd/config/batchd.admin.yaml upgrade-db"
    info "Creating the super user whose name is root, if prompt, you should input the password for root twice"
    sudo sg docker -c "docker run -it --rm -e BATCHD_ROOT_PASSWORD=${MY_BATCHD_ROOT_PASSWORD} -v /var/batchd/config:/var/batchd/config ${batchd_IMAGE_ID} ${cmdPath}/bin/batchd-admin --config /var/batchd/config/batchd.admin.yaml create-superuser"
    info "create following schedule:"
    curl -X POST -u "root:${MY_BATCHD_ROOT_PASSWORD}" "http://localhost:9681/schedule" -d '{"time": [{"begin": "00:00:00",  "end": "23:59:59"}],  "weekdays": ["Sunday", "Monday", "Tuesday",  "Wednesday",  "Thursday",  "Friday", "Saturday"],  "name": "anytime"}'
    echo ""
    curl -X POST -u "root:${MY_BATCHD_ROOT_PASSWORD}" "http://localhost:9681/schedule" -d '{"time": [{"begin": "08:00:00",  "end": "18:00:00"}],  "weekdays": ["Monday", "Tuesday",  "Wednesday",  "Thursday",  "Friday"],  "name": "working.hours"}'
    echo ""
    info "create following queue:"
    curl -X POST -u "root:${MY_BATCHD_ROOT_PASSWORD}" "http://localhost:9681/queue" -d '{"name":"anytime.jobs.on.scaleway.test",  "schedule_name":"anytime",  "host_name":"scaleway.test", "title": "Queue holding jobs running anytime on scaleway.test", "enabled": true}'
    echo ""
fi

done_banner "batchd" "deploy finishing"
