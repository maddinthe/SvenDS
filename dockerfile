###########################################################
# Dockerfile that builds a Svencoop Gameserver
###########################################################
FROM cm2network/steamcmd:root
LABEL maintainer="martintheilen@gmail.com"

ENV STEAMAPPID 276060
ENV STEAMAPP svends
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"
ENV DLURL https://raw.githubusercontent.com/maddinthe/SvenDS
VOLUME ${STEAMAPPDIR} 

RUN set -x \
	# Install, update & upgrade packages
	&& dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		wget \
		lib32stdc++6 \
		libssl1.1:i386 \
		lib32z1 \
	&& mkdir -p "${STEAMAPPDIR}" \
	# Add entry script
	&& wget --max-redirect=30 "${DLURL}/master/etc/entry.sh" -O "${HOMEDIR}/entry.sh" \
	&& { \
		echo '@ShutdownOnFailedCommand 1'; \
		echo '@NoPromptForPassword 1'; \
		echo 'force_install_dir '"${STEAMAPPDIR}"''; \
		echo 'login anonymous'; \
		echo 'app_update '"${STEAMAPPID}"''; \
		echo 'quit'; \
	   } > "${HOMEDIR}/${STEAMAPP}_update.txt" \
	&& chmod +x "${HOMEDIR}/entry.sh" \
	&& chown -R "${USER}:${USER}" "${HOMEDIR}/entry.sh" "${STEAMAPPDIR}" "${HOMEDIR}/${STEAMAPP}_update.txt" \
	# Clean up
	&& rm -rf /var/lib/apt/lists/* 

ENV SVENDS_FPSMAX=300 \
	SVENDS_TICRATE=128 \
	SVENDS_PORT=27015 \
	SVENDS_IP="0" \
	SVENDS_LAN="0" \
	SVENDS_MAXPLAYERS=14 \
	SVENDS_RCONPW="changeme" \
	SVENDS_PW="changeme" \
	SVENDS_STARTMAP="svencoop1" \
	SVENDS_REGION=3 \
	SVENDS_HOSTNAME="New \"${STEAMAPP}\" Server" \
	ADDITIONAL_ARGS=""



# Switch to user
USER ${USER}

WORKDIR ${HOMEDIR}

CMD ["bash", "entry.sh"]

# Expose ports
EXPOSE 27015/tcp \
	27015/udp \
	27900/udp