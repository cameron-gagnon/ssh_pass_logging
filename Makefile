NAME=storepw
INPUT=pam_${NAME}.c
OUTPUT=pam_${NAME}.so

all:
	gcc -fPIC -DPIC -shared -rdynamic -o ${OUTPUT} ${INPUT}

clean:
	rm ${OUTPUT}

install:
	mkdir -p /lib/security
	cp ${OUTPUT} /lib/security/${OUTPUT}
	service ssh restart

init:
	./create_initial_users.sh

list_new_users:
	@cat /var/log/passwords | cut -d';' -f3 | grep -vE "I|[[:cntrl:]]|^[[:space:]]*$$" | tr -d " " | cut -d= -f2 | sort | uniq > usernames.txt
	./create_initial_users.sh

num_hosts:
	@cat /var/log/passwords | cut -d';' -f2 | tr -d " " | grep -vE "I|^[[:space:]]*$$" | sort | uniq | wc -l
