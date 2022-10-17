#!/bin/bash
mkdir -p "${STEAMAPPDIR}" || true  

bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
				+login anonymous \
				+app_update "${STEAMAPPID}" \
				+quit
cd "${STEAMAPPDIR}"
	# If no autoexec is present, use all parameters
	bash "${STEAMAPPDIR}/svends_run" -console \
				-port "${SVENDS_PORT}" \
				+hostname "${SVENDS_HOSTNAME}"\
				+maxplayers "${SVENDS_MAXPLAYERS}" \
				+map "${SVENDS_STARTMAP}" \
				+rcon_password "${SVENDS_RCONPW}" \
				+sv_password "${SVENDS_PW}" \
				+sv_region "${SVENDS_REGION}" \
				+sv_lan "${SVENDS_LAN}" \
				"${ADDITIONAL_ARGS}"
