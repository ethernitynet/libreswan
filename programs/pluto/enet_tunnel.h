
#ifndef _ENET_TUNNEL_H_
#define _ENET_TUNNEL_H_

#include <string.h>
#include <curl/curl.h>
#include <stdlib.h>

typedef enum {
	
	ENET_TUNNEL_ADD_OUTBOUND = 0,
	ENET_TUNNEL_ADD_INBOUND,
	////////////////////
	ENET_TUNNEL_TYPES_COUNT
} enet_tunnel_config_type;

typedef struct {
	
	enet_tunnel_config_type config_type;
	unsigned char *vpn_gw_ip;
	unsigned char *remote_tunnel_endpoint_ip;
	unsigned char *local_subnet;
	unsigned int local_subnet_mask;
	unsigned char *remote_subnet;
	unsigned int remote_subnet_mask;
	unsigned int spi;
	const char *auth_algo;
	unsigned int auth_keylen;
	const unsigned char *auth_key;
	const char *cipher_algo;
	unsigned int cipher_keylen;
	const unsigned char *cipher_key;
} enet_tunnel_config;

#define OUTBOUND_TUNNEL_ADD_FORMAT "{\
\"op\": \"outbound_tunnel_add\",\
\"tunnel_spec\": {\
\"remote_tunnel_endpoint_ip\": \"%u.%u.%u.%u\",\
\"local_subnet\": \"%u.%u.%u.%u/%u\",\
\"remote_subnet\": \"%u.%u.%u.%u/%u\"\
},\
\"ipsec_cfg\": {\
\"spi\": %u,\
\"auth_algo\": \"%s\",\
\"cipher_algo\": \"%s\",\
\"auth_key\": \"%s\",\
\"cipher_key\": \"%s\"\
},\
\"meta\": {\
\"ip_neigh\": %s\
}\
}"

#define INBOUND_TUNNEL_ADD_FORMAT "{\
\"op\": \"inbound_tunnel_add\",\
\"tunnel_spec\": {\
\"remote_tunnel_endpoint_ip\": \"%u.%u.%u.%u\",\
\"local_subnet\": \"%u.%u.%u.%u/%u\",\
\"remote_subnet\": \"%u.%u.%u.%u/%u\"\
},\
\"ipsec_cfg\": {\
\"spi\": %u,\
\"auth_algo\": \"%s\",\
\"cipher_algo\": \"%s\",\
\"auth_key\": \"%s\",\
\"cipher_key\": \"%s\"\
},\
\"meta\": {\
\"ip_neigh\": %s\
}\
}"


#if 0
static void enet_tunnel_cmd(const char *uri, const char *cmd) {
	
	loglog(RC_LOG_SERIOUS, "enet> %s", cmd);
	CURL *curl = curl_easy_init();
	
	if (curl != NULL) {
		CURLcode res;
		curl_easy_setopt(curl, CURLOPT_URL, uri);
		curl_easy_setopt(curl, CURLOPT_POSTFIELDS, cmd);
		curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)strlen(cmd));
		res = curl_easy_perform(curl);
		if(res != CURLE_OK) {
			fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
		};
		curl_easy_cleanup(curl);
	};
};
#endif

static void enet_tunnel_cmd(const char *uri, const char *cmd) {

	char curl_str[2048];
	
	sprintf(curl_str, "curl -fsSL -d '%s' -H \"Content-Type: application/json\" -X POST %s &", cmd, uri);
	loglog(RC_LOG_SERIOUS, "enet> %s", curl_str);
	FILE *fpipe = (FILE *)popen(curl_str, "r");
	fflush(fpipe);
	pclose(fpipe);
};

static const char *key_to_str(char *key_str, const unsigned char *key, const unsigned int key_len) {
	
	const char *key_str_head = key_str;
	unsigned int i;
	for(i = 0; i < key_len; ++i) {
		key_str += sprintf(key_str, "%02X", key[i]);
	};
	return key_str_head;
};

static const char *ip_neigh_to_str(char *ip_neigh_str) {
	
	const char *ip_neigh_str_head = ip_neigh_str;
	char pline[1024];
	FILE *fpipe = (FILE *)popen("ip neigh", "r");
	
	ip_neigh_str += sprintf(ip_neigh_str, "[");
	fflush(fpipe);
	if(fgets(pline, sizeof(pline), fpipe)) {
		if(pline[strlen(pline) - 1] == '\n') {
			pline[strlen(pline) - 1] = '\0';
		};
		ip_neigh_str += sprintf(ip_neigh_str, "\"%s\"", pline);
	};
	while(fgets(pline, sizeof(pline), fpipe)) {
		if(pline[strlen(pline) - 1] == '\n') {
			pline[strlen(pline) - 1] = '\0';
		};
		ip_neigh_str += sprintf(ip_neigh_str, ",\"%s\"", pline);
	};
	fflush(fpipe);
	pclose(fpipe);
	ip_neigh_str += sprintf(ip_neigh_str, "]");
	return ip_neigh_str_head;
};

static void enet_tunnel_config_apply(const enet_tunnel_config *config) {
	
	char cmd_str[2048];
	char auth_key_str[1024];
	char cipher_key_str[1024];
	char ip_neigh_str[4096];
		
	switch(config->config_type) {
		
		case ENET_TUNNEL_ADD_OUTBOUND:
		sprintf(cmd_str, OUTBOUND_TUNNEL_ADD_FORMAT,
			config->remote_tunnel_endpoint_ip[0], config->remote_tunnel_endpoint_ip[1], config->remote_tunnel_endpoint_ip[2], config->remote_tunnel_endpoint_ip[3],
			config->local_subnet[0], config->local_subnet[1], config->local_subnet[2], config->local_subnet[3], config->local_subnet_mask,
			config->remote_subnet[0], config->remote_subnet[1], config->remote_subnet[2], config->remote_subnet[3], config->remote_subnet_mask,
			config->spi,
			config->auth_algo,
			config->cipher_algo,
			key_to_str(auth_key_str, config->auth_key, config->auth_keylen),
			key_to_str(cipher_key_str, config->cipher_key, config->cipher_keylen),
			ip_neigh_to_str(ip_neigh_str)
			);
		break;
		
		case ENET_TUNNEL_ADD_INBOUND:
		sprintf(cmd_str, INBOUND_TUNNEL_ADD_FORMAT,
			config->remote_tunnel_endpoint_ip[0], config->remote_tunnel_endpoint_ip[1], config->remote_tunnel_endpoint_ip[2], config->remote_tunnel_endpoint_ip[3],
			config->local_subnet[0], config->local_subnet[1], config->local_subnet[2], config->local_subnet[3], config->local_subnet_mask,
			config->remote_subnet[0], config->remote_subnet[1], config->remote_subnet[2], config->remote_subnet[3], config->remote_subnet_mask,
			config->spi,
			config->auth_algo,
			config->cipher_algo,
			key_to_str(auth_key_str, config->auth_key, config->auth_keylen),
			key_to_str(cipher_key_str, config->cipher_key, config->cipher_keylen),
			ip_neigh_to_str(ip_neigh_str)
			);
		break;
		
		default:
		return;
	};
	enet_tunnel_cmd(getenv("ENET_VPN_URI"), cmd_str);
};

#endif /* _ENET_TUNNEL_H_ */
