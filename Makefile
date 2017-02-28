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
