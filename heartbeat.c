#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <sys/socket.h>
#include <netinet/ip.h>
#include <netinet/udp.h>
#include <arpa/inet.h>
#include <fcntl.h>
#include <net/if.h>

unsigned short csum(unsigned short *ptr, int nbytes) {
	long sum;
	unsigned short oddbyte;
	short answer;
	sum = 0;
	while(nbytes > 1) {
		sum += *ptr++;
		nbytes -= 2;
	}
	if(nbytes == 1) {
		oddbyte = 0;
		*((u_char*)&oddbyte) = *(u_char*)ptr;
		sum += oddbyte;
	}
	sum = (sum >> 16) + (sum & 0xffff);
	sum += (sum >> 16);
	answer = (short)~sum;
	return answer;
}

double get_entropy_jitter() {
	unsigned char rand_byte;
	FILE *f = fopen("/dev/urandom", "rb");
	fread(&rand_byte, 1, 1, f);
	fclose(f);
	return ((double)rand_byte / 255.0) * 0.040 + 0.010;
}

double get_dns_iat() {
	unsigned int rand_val;
	FILE *f = fopen("/dev/urandom", "rb");
	fread(&rand_val, sizeof(rand_val), 1, f);
	fclose(f);
	return 0.5 + ((double)(rand_val % 2500) / 1000.0);
}

int main(int argc, char *argv[]) {
	srand(time(NULL));
	int urandom_fd = open("/dev/urandom", O_RDONLY);
	if(urandom_fd < 0) exit(1);

	int sock = socket(AF_INET, SOCK_RAW, IPPROTO_RAW);
	if(sock < 0) exit(1);

	// Explicit Bind to Lokinet Interface
	struct ifreq ifr;
	memset(&ifr, 0, sizeof(ifr));
	snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), "lokitun0");
	setsockopt(sock, SOL_SOCKET, SO_BINDTODEVICE, (void *)&ifr, sizeof(ifr));

	int one = 1;
	setsockopt(sock, IPPROTO_IP, IP_HDRINCL, &one, sizeof(one));

	char packet[4096];
	struct iphdr *iph = (struct iphdr *) packet;
	struct udphdr *udph = (struct udphdr *) (packet + sizeof(struct iphdr));

	struct sockaddr_in sin;
	sin.sin_family = AF_INET;
	sin.sin_addr.s_addr = inet_addr("127.0.0.1");

	struct timespec req, rem;
	time_t last_dns_time = time(NULL);

	while(1) {
		// --- PRE-RANDOMIZATION ENTROPY IAT ---
		struct timespec pre_iat;
		pre_iat.tv_sec = 0;
		pre_iat.tv_nsec = (rand() % 50000000);
		nanosleep(&pre_iat, NULL);

		time_t curr_time = time(NULL);

		// Simulated DNS-over-Lokinet Entropy
		if(difftime(curr_time, last_dns_time) > get_dns_iat()) {
			memset(packet, 0, 4096);
			iph->ihl = 5; iph->version = 4; iph->tos = 0;
			iph->tot_len = sizeof(struct iphdr) + sizeof(struct udphdr) + 32;
			iph->id = htons(rand() % 65535); iph->frag_off = 0; iph->ttl = 128;
			iph->protocol = IPPROTO_UDP; iph->daddr = sin.sin_addr.s_addr;
			iph->check = csum((unsigned short *) packet, iph->tot_len);
			udph->source = htons(49152 + (rand() % 16383));
			udph->dest = htons(1090);
			udph->len = htons(sizeof(struct udphdr) + 32);
			char *dns_data = packet + sizeof(struct iphdr) + sizeof(struct udphdr);

			read(urandom_fd, dns_data, 32);
			dns_data[2] = 0x01;

			sendto(sock, packet, iph->tot_len, 0, (struct sockaddr *)&sin, sizeof(sin));
			last_dns_time = curr_time;
		}

		// Chaff HTTP/2 Randomization Burst
		int burst_size = 10 + (rand() % 13);
		for(int b = 0; b < burst_size; b++) {
			// MTU Clamping between 1200 and 1400
			int current_mtu_limit = (rand() % (1400 - 1200 + 1)) + 1200;
			int jittered_payload_size = current_mtu_limit - 42;

			memset(packet, 0, 4096);
			iph->ihl = 5; iph->version = 4; iph->tos = 0;
			iph->tot_len = sizeof(struct iphdr) + sizeof(struct udphdr) + jittered_payload_size;
			iph->id = htons(rand() % 65535); iph->frag_off = 0; iph->ttl = 64 + (rand() % 64);
			iph->protocol = IPPROTO_UDP;
			iph->daddr = sin.sin_addr.s_addr;
			iph->check = csum((unsigned short *) packet, iph->tot_len);

			udph->source = htons(443);
			udph->dest = htons(1090);
			udph->len = htons(sizeof(struct udphdr) + jittered_payload_size);
			udph->check = 0;

			char *payload = packet + sizeof(struct iphdr) + sizeof(struct udphdr);
			read(urandom_fd, payload, jittered_payload_size);

			struct timespec chunk_iat;
			chunk_iat.tv_sec = 0;
			chunk_iat.tv_nsec = (rand() % 50000);
			nanosleep(&chunk_iat, NULL);

			sendto(sock, packet, iph->tot_len, 0, (struct sockaddr *)&sin, sizeof(sin));
		}

		// --- POST-RANDOMIZATION ENTROPY IAT ---
		double jitter = get_entropy_jitter();
		req.tv_sec = 0;
		req.tv_nsec = (long)(jitter * 1000000000.0);
		nanosleep(&req, &rem);
	}
	return 0;
}
