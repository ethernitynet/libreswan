
#include <string.h>
#include <curl/curl.h>
#include "enet_tunnel.h"

const char outbound_tunnel_add_format[] = 
"{\n\
	\"op\": \"outbound_tunnel_add\",\n\
	\"tunnel_spec\": {\n\
		\"remote_tunnel_endpoint_ip\": \"%u.%u.%u.%u\",\n\
		\"local_subnet\": \"%u.%u.%u.%u/%u\",\n\
		\"remote_subnet\": \"%u.%u.%u.%u/%u\"\n\
	},\n\
	\"ipsec_cfg\": {\n\
		\"spi\": %u,\n\
		\"auth_algo\": %s,\n\
		\"cipher_algo\": \"%s\",\n\
		\"auth_key\": \"%s\",\n\
		\"cipher_key\": \"%s\"\n\
	}\n\
}\n";

const char inbound_tunnel_add_format[] = 
"{\n\
	\"op\": \"inbound_tunnel_add\",\n\
	\"tunnel_spec\": {\n\
		\"remote_tunnel_endpoint_ip\": \"%u.%u.%u.%u\",\n\
		\"local_subnet\": \"%u.%u.%u.%u/%u\",\n\
		\"remote_subnet\": \"%u.%u.%u.%u/%u\"\n\
	},\n\
	\"ipsec_cfg\": {\n\
		\"spi\": %u,\n\
		\"auth_algo\": %s,\n\
		\"cipher_algo\": \"%s\",\n\
		\"auth_key\": \"%s\",\n\
		\"cipher_key\": \"%s\"\n\
	}\n\
}\n";


void enet_tunnel_cmd(const char *uri, const char *cmd) {
	
	printf("%s\n", cmd);
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

static const char *key_to_str(char *key_str, const unsigned char *key, const unsigned int key_len) {
	
	const char *key_str_head = key_str;
	unsigned int i;
	for(i = 0; i < key_len; ++i) {
		key_str += sprintf(key_str, "%02X", key[i]);
	};
	return key_str_head;
};

void enet_tunnel_config_apply(const char *uri, const enet_tunnel_config *config) {
	
	char cmd_str[2048];
	char auth_key_str[1024];
	char cipher_key_str[1024];
		
	const char *tunnel_config_format = NULL;
	switch(config->config_type) {
		case ENET_TUNNEL_ADD_OUTBOUND:
		tunnel_config_format = outbound_tunnel_add_format;
		break;
		case ENET_TUNNEL_ADD_INBOUND:
		tunnel_config_format = inbound_tunnel_add_format;
		break;
	};
	sprintf(cmd_str, tunnel_config_format,
		config->remote_tunnel_endpoint_ip[0], config->remote_tunnel_endpoint_ip[1], config->remote_tunnel_endpoint_ip[2], config->remote_tunnel_endpoint_ip[3],
		config->local_subnet[0], config->local_subnet[1], config->local_subnet[2], config->local_subnet[3], config->local_subnet_mask,
		config->remote_subnet[0], config->remote_subnet[1], config->remote_subnet[2], config->remote_subnet[3], config->remote_subnet_mask,
		config->spi,
		config->auth_algo,
		config->cipher_algo,
		key_to_str(auth_key_str, config->auth_key, config->auth_keylen),
		key_to_str(cipher_key_str, config->cipher_key, config->cipher_keylen)
		);
	enet_tunnel_cmd(uri, cmd_str);
};
