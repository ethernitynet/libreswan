
#ifndef _ENET_TUNNEL_CONFIG_PARSE_H_
#define _ENET_TUNNEL_CONFIG_PARSE_H_

#include "enet_tunnel.h"
#include "kernel.h"
#include "connections.h"
#include "ike_alg.h"

#define ENET_CIPHER_OVERRIDE

#define NULL_KEYLEN (2)
static const unsigned char null_key[NULL_KEYLEN] = { 0x00, 0x00 };

static void enet_tunnel_config_parse(enet_tunnel_config *config, const struct kernel_sa *sa, const struct connection *c) {
	
	if(sa->inbound) {
		config->vpn_gw_ip = (unsigned char *)&(sa->dst->u.v4.sin_addr);
		config->remote_tunnel_endpoint_ip = (unsigned char *)&(sa->src->u.v4.sin_addr);
		config->config_type = ENET_TUNNEL_ADD_INBOUND;
	}
	else {
		config->vpn_gw_ip = (unsigned char *)&(sa->src->u.v4.sin_addr);
		config->remote_tunnel_endpoint_ip = (unsigned char *)&(sa->dst->u.v4.sin_addr);
		config->config_type = ENET_TUNNEL_ADD_OUTBOUND;
	};
	config->local_subnet = (unsigned char *)&(c->spd.this.client.addr.u.v4.sin_addr);
	config->local_subnet_mask = (unsigned int)(c->spd.this.client.maskbits);
	config->remote_subnet = (unsigned char *)&(c->spd.that.client.addr.u.v4.sin_addr);
	config->remote_subnet_mask = (unsigned int)(c->spd.that.client.maskbits);
	config->spi = sa->spi;
	
#ifdef ENET_CIPHER_OVERRIDE
	config->auth_algo = "null";
	config->auth_keylen = NULL_KEYLEN;
	config->auth_key = null_key;
	config->cipher_algo = "aes_gcm128-null";
#else
	config->auth_algo = sa->integ->common.fqn;
	config->auth_keylen = sa->authkeylen;
	config->auth_key = sa->authkey;
	config->cipher_algo = sa->encrypt->common.fqn;
#endif

	config->cipher_keylen = sa->enckeylen;
	config->cipher_key = sa->enckey;
};

#endif /* _ENET_TUNNEL_CONFIG_PARSE_H_ */
