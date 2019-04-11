
#include <string.h>
#include <curl/curl.h>

const char outbound_tunnel_add_format[] = 
"{\n\
	\"op\": \"outbound_tunnel_add\",\n\
	\"tunnel_spec\": {\n\
		\"remote_tunnel_endpoint_ip\": \"%s\",\n\
		\"local_subnet\": \"%s\",\n\
		\"remote_subnet\": \"%s\"\n\
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

void enet_tunnel_outbound_add() {
	
	char cmd_str[2048];
	
	sprintf(cmd_str, outbound_tunnel_add_format,
		"10.168.22.1",
		"140.0.1.0/24",
		"140.0.2.0/24",
		400104410,
		"null",
		"aes_gcm128-null",
		"00",
		"b001047472a30e67fda11c63689c453434bdf8df"
		);
	enet_tunnel_cmd("http://172.17.0.1:44000", cmd_str);
};
