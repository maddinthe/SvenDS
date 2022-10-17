#!/bin/bash
mkdir -p "${STEAMAPPDIR}" || true  

bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
				+login anonymous \
				+app_update "${STEAMAPPID}" \
				+quit

# Is the config missing?
if [ ! -f "${STEAMAPPDIR}/${STEAMAPP}/cfg/server.cfg" ]; then
	# Download & extract the config
	wget -qO- "${DLURL}/raw/master/etc/cfg.tar.gz" | tar xvzf - -C "${STEAMAPPDIR}/${STEAMAPP}"

	# Change hostname on first launch (you can comment this out if it has done its purpose)
	sed -i -e 's/{{SERVER_HOSTNAME}}/'"${SRCDS_HOSTNAME}"'/g' "${STEAMAPPDIR}/${STEAMAPP}/cfg/server.cfg"
fi
# Believe it or not, if you don't do this srcds_run shits itself
cd "${STEAMAPPDIR}"

# Check if autoexec file exists
# Passing arguments directly to srcds_run, ignores values set in autoexec.cfg
autoexec_file="${STEAMAPPDIR}/${STEAMAPP}/cfg/autoexec.cfg"

# Overwritable arguments
ow_args=""

# If you need to overwrite a specific launch argument, add it to this loop and drop it from the subsequent srcds_run call
if [ -f "$autoexec_file" ]; then
        # TAB delimited name    default
        # HERE doc to not add extra file
        while IFS=$'\t' read -r name default
        do
                if ! grep -q "^\s*$name" "$autoexec_file"; then
                        ow_args="${ow_args} $default"
                fi
        done <<EOM
sv_password	+sv_password "${SRCDS_PW}"
rcon_password	+rcon_password "${SRCDS_RCONPW}"
EOM
	# if autoexec is present, drop overwritten arguments here (example: SRCDS_PW & SRCDS_RCONPW)
	bash "${STEAMAPPDIR}/svends_run" -console -autoupdate \
				+fps_max "${SVENDS_FPSMAX}" \
				+sys_ticrate "${SVENDS_TICKRATE}" \
				-port "${SVENDS_PORT}" \
				+maxplayers "${SVENDS_MAXPLAYERS}" \
				+map "${SVENDS_STARTMAP}" \
				+sv_region "${SVENDS_REGION}" \
				+ip "${SVENDS_IP}" \
				+sv_lan "${SVENDS_LAN}" \
				"${ow_args}" \
				"${ADDITIONAL_ARGS}"
else
	# If no autoexec is present, use all parameters
	bash "${STEAMAPPDIR}/svends_run" -console \
				+fps_max "${SVENDS_FPSMAX}" \
				+sys_ticrate "${SVENDS_TICKRATE}" \
				-port "${SVENDS_PORT}" \
				+maxplayers "${SVENDS_MAXPLAYERS}" \
				+map "${SVENDS_STARTMAP}" \
				+rcon_password "${SVENDS_RCONPW}" \
				+sv_password "${SVENDS_PW}" \
				+sv_region "${SVENDS_REGION}" \
				-ip "${SVENDS_IP}" \
				+sv_lan "${SVENDS_LAN}" \
				"${ADDITIONAL_ARGS}"
fi