#!/bin/bash

if [ ! -d "${HOME}/scripts" ]; then
	mkdir -p ${HOME}/scripts
fi

# Clone the qbit_manage files
if [ ! -d "${HOME}/scripts/qbit_manage" ]; then
	pushd ${HOME}/scripts > /dev/null
	git clone https://github.com/StuffAnThings/qbit_manage
	popd > /dev/null
else
	# Ensure the repo is up to date
	pushd ${HOME}/scripts/qbit_manage > /dev/null
	git config pull.ff only > /dev/null
	git pull > /dev/null
	popd > /dev/null
fi

# Enable the virtual environment, if it doesn't exist already
if [ ! -d "${HOME}/scripts/.venv_qbit_manage" ]; then
    python3 -m virtualenv "${HOME}/scripts/.venv_qbit_manage"
fi

# Copy the config file if it does not already exist
if [ ! -f "${HOME}/.config/qbit_manage.yml" ]; then
    if [ ! -d "${HOME}/config" ]; then
        mkdir -p ${HOME}/.config
    fi
    cp ${HOME}/scripts/qbit_manage/config/config.yml.sample ${HOME}/.config/qbit_manage.yml
    chmod 660 ${HOME}/.config/qbit_manage.yml
fi

# Logs dir
if [ ! -d "${HOME}/logs/qbit_manage" ]; then
    mkdir -p ${HOME}/logs/qbit_manage
fi

# Check the systemd path exists
if [ ! -f "${HOME}/.config/systemd/user" ]; then
    mkdir -p ${HOME}/.config/systemd/user
fi

# Create the systemd unit file
if [ ! -f "${HOME}/.config/systemd/user/qbit_manage.service" ]; then
    printf "[Unit]\nDescription=qbit_manage service\nAfter=syslog.target network-online.target\n" > ${HOME}/.config/systemd/user/qbit_manage.service
    printf "[Service]\nType=simple\nExecStart=${HOME}/scripts/qbit_manage_run.sh\n" >> ${HOME}/.config/systemd/user/qbit_manage.service
    printf "[Install]\nWantedBy=default.target" >> ${HOME}/.config/systemd/user/qbit_manage.service
fi

if [ -d "${HOME}/scripts/.venv_qbit_manage" ]; then
    source ${HOME}/scripts/.venv_qbit_manage/bin/activate
    pip install -q -r ${HOME}/scripts/qbit_manage/requirements.txt --ignore-installed
    echo "The environment should now be ready for use"
else
	echo "Cannot find the Python Virtual Environment, exiting"
	exit 1
fi

if [ ! -f "${HOME}/scripts/qbit_manage_run.sh" ]; then
	echo -e "#!/bin/bash\nsource ${HOME}/scripts/.venv_qbit_manage/bin/activate\n" > ${HOME}/scripts/qbit_manage_run.sh
	echo -e "find ${HOME}/logs/qbit_manage/* -mtime +7 -exec {} \;" >> ${HOME}/scripts/qbit_manage_run.sh
	echo -e "pip install -q -r ${HOME}/scripts/qbit_manage/requirements.txt --ignore-installed" >> ${HOME}/scripts/qbit_manage_run.sh
	echo -e "python ${HOME}/scripts/qbit_manage/qbit_manage.py --config-file ${HOME}/.config/qbit_manage.yml --log-file ${HOME}/logs/qbit_manage/\$(date +%Y%m%d).log" >> ${HOME}/scripts/qbit_manage_run.sh
	chmod +x ${HOME}/scripts/qbit_manage_run.sh
fi

systemctl enable --now --user qbit_manage.service > /dev/null

echo "Edit the ${HOME}/.config/qbit_manage.yml file, then run:"
echo -e "systemctl restart --user qbit_manage.service"
echo -e "Check the log file in ${HOME}/logs/qbit_manage/"
