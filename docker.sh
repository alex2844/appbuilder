function fetch() {
	$(echo $([ `type -p curl` ] && echo "curl -s" || echo "wget -q -O -")" "$1);
}
if [ -f /.dockerenv ]; then
    echo "Hmmmm...."; # change platform android, linux, windows
else
	if [ 1500000 -ge $(echo $(free | awk '/^Mem:/{print $4}')+$(free | awk '/^Swap:/{print $4}') | bc) ]; then
		if [ ! -e "$HOME/.swapfile" ]; then
			if [[ `type -p mkswap` ]]; then
				fallocate -l 1024M "$HOME/.swapfile";
				chmod 600 "$HOME/.swapfile";
				mkswap "$HOME/.swapfile";
				swapon "$HOME/.swapfile";
				swapon -s;
				echo "$HOME/.swapfile   none    swap    sw    0   0" >> /etc/fstab;
			fi
		fi
	fi
	if [ "$1" == "" ] || [ "$1" == "help" ]; then
		echo '---------------';
		echo 'Help AppBuilder';
		echo '---------------';
		echo "$0 install";
		echo "$0 build";
		echo "$0 shell - debug";
		exit;
	elif [ "$1" == "install" ]; then
		bash <(fetch "https://get.docker.com/");
	elif [ "$1" == "shell" ]; then
		docker run --rm -v "$PWD":/home/gradle/:cached -i -t appbuilder bash;
	elif [ "$1" == "make" ]; then
		docker image rm appbuilder;
		docker build -t appbuilder .;
	elif [ "$1" == "build" ]; then
		docker run --rm -v "$PWD":/home/gradle/:cached appbuilder;
	fi
fi

# https://docs.docker.com/develop/sdk/
# https://docs.docker.com/engine/api/v1.40/
# curl -s --unix-socket /var/run/docker.sock "http:/v1.40/images/json"
