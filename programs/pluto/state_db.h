/* State table indexed by serialno, for libreswan
 *
 * Copyright (C) 2017-2018 Andrew Cagney
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.  See <https://www.gnu.org/licenses/gpl2.txt>.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for more details.
 */

#ifndef STATE_DB_H
#define STATE_DB_H

#include "ike_spi.h"

struct state;
struct list_entry;

void init_state_db(void);

void add_state_to_db(struct state *st);
void rehash_state_cookies_in_db(struct state *st);
void del_state_from_db(struct state *st);

struct state *state_by_serialno(so_serial_t serialno);

/*
 * List of all valid states; can be iterated in old-to-new and
 * new-to-old order.
 */

extern struct list_head serialno_list_head;

#define FOR_EACH_STATE_NEW2OLD(ST)				\
	FOR_EACH_LIST_ENTRY_NEW2OLD(&serialno_list_head, ST)

#define FOR_EACH_STATE_OLD2NEW(ST)				\
	FOR_EACH_LIST_ENTRY_OLD2NEW(&serialno_list_head, ST)


/*
 * Return the slot for the given hash value.  It will contain may
 * entries, not just the specified value.  Extra filtering is
 * required!
 */

struct list_head *ike_initiator_spi_slot(const ike_spi_t *initiator);
struct list_head *ike_spis_slot(const ike_spis_t *spis);
struct list_head *ike_spi_slot(const ike_spi_t *initiator,
			       const ike_spi_t *responder);

#endif
