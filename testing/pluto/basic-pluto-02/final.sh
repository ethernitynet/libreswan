ipsec look
: ==== cut ====
ipsec auto --status
: ==== tuc ====
ipsec whack --shutdown
../bin/check-for-core.sh
if [ -f /sbin/ausearch ]; then ausearch -r -m avc -ts recent ; fi
: ==== end ====
