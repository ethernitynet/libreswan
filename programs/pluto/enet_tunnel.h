
#ifndef _ENET_TUNNEL_H_
#define _ENET_TUNNEL_H_

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

void enet_tunnel_config_apply(const char *uri, const enet_tunnel_config *config);

#endif /* _ENET_TUNNEL_H_ */
