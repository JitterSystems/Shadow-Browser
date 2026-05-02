#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>

void stop_shadownet() {
	printf("\033[1;31m[*] Tearing down ShadowNet Local Engines...\033[0m\n");
	system("pkill -f 'shadownet_engine'");
	system("pkill -f 'heartbeat'");
	system("pkill -f 'tor -f /tmp/shadow_torrc'");
	system("rm -f /tmp/shadow_torrc");
	printf("\033[1;31m[-] ShadowNet Deactivated. Traces cleared.\033[0m\n");
}

void start_shadownet() {
	if (access("./heartbeat", F_OK) == -1 || access("./shadownet_engine", F_OK) == -1) {
		printf("\033[0;31m[!] CRITICAL: heartbeat or shadownet_engine binaries missing. Compile them first.\033[0m\n");
		exit(1);
	}

	printf("\033[1;30m[*] Initializing Isolated ShadowNet Proxy...\033[0m\n");

	FILE *torrc = fopen("/tmp/shadow_torrc", "w");
	if (torrc) {
		fprintf(torrc, "SocksPort 127.0.0.1:9050 IsolateDestAddr IsolateDestPort IsolateClientAddr IsolateClientProtocol IsolateSOCKSAuth\n");
		fprintf(torrc, "DataDirectory /tmp/shadow_tor_data\n");
		fprintf(torrc, "CircuitPadding 1\n");
		fprintf(torrc, "ConnectionPadding 1\n");
		fprintf(torrc, "ReducedConnectionPadding 0\n");
		fprintf(torrc, "ReducedCircuitPadding 0\n");
		fprintf(torrc, "UseBridges 1\n");
		fprintf(torrc, "ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy\n");
		fprintf(torrc, "Bridge obfs4 89.116.48.119:32278 EB1331E3372F12A1B42D2A8ECAF7064251C56B66 cert=pfjOWyOhh7bEcZUtKekBFbBPKSnhWjS4yyFG+/n0Foq3Bq6m8gsLecMHBf9K01a/wLiNAQ iat-mode=0\n");
		fprintf(torrc, "Bridge obfs4 100.8.170.63:50164 FBA329BA4F5FE648456C3A28BBAA3C7EBD118E08 cert=DKA6xS0N6c4I1CFVmWc/qgAEhPBgR/dPQyXhbkjt082Ka2xmq1pwSUpCPt626uuKW2Z1TA iat-mode=0\n");
		fclose(torrc);
	} else {
		printf("\033[0;31m[!] Failed to write isolated proxy config.\033[0m\n");
		exit(1);
	}

	printf("\033[1;34m[*] Establishing 6-Hop Circuitry via obfs4 Bridges...\033[0m\n");
	system("tor -f /tmp/shadow_torrc > /dev/null 2>&1 &");

	printf("\033[1;35m[*] Engaging Temporal Jitter & UDP Noise...\033[0m\n");
	system("sudo ./shadownet_engine 127.0.0.1 > /dev/null 2>&1 &");
	system("sudo ./heartbeat 1200 > /dev/null 2>&1 &");

	sleep(2);
	printf("\033[0;32m[+] ShadowNet Proxy Active.\033[0m\n");
}

int main(int argc, char *argv[]) {
	if (argc < 2) {
		printf("\033[0;31mUsage: ./shadownet_isolated {start|stop}\033[0m\n");
		return 1;
	}
	if (strcmp(argv[1], "start") == 0) {
		start_shadownet();
	} else if (strcmp(argv[1], "stop") == 0) {
		stop_shadownet();
	}
	return 0;
}
