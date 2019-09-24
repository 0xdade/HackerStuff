#!/usr/bin/env python
'''
File: dnssec-walker.py
Author: @0xdade
Description: Simple DNSSEC record walker. Crawls NSEC records of a target domain.
License: WTFPL (http://www.wtfpl.net/)
Requires:
    - pip install dnspython
'''

import dns.resolver
import dns.rdatatype
import dns.query
import sys

def main():
    targetDomain = sys.argv[1] # pass in a target domain to walk

    # If the provided domain doesn't end with a '.', add one so that we can compare against the actual DNS records
    if not targetDomain.endswith('.'):
        targetDomain+='.'
    #print("Target Domain: %s" % targetDomain)

    # we set nextDomain so that we can loop starting at the beginning
    nextDomain = targetDomain
    resolv = dns.resolver.Resolver()

    # Get and then set the authoritative nameservers
    nsnames = resolv.query(targetDomain, dns.rdatatype.NS).rrset
    nsaddrs = []
    for name in nsnames:
        # take the first A record for the name and append it to our nameserver list
        nsaddrs.append(resolv.query(str(name), dns.rdatatype.A).rrset[0].to_text())
    resolv.nameservers = nsaddrs

    while nextDomain:
        outstr = str(nextDomain)[:-1] + " "
        try:
            arec = resolv.query(nextDomain, 'A')
            for rdata in arec:
                outstr += str(rdata) + ","
        except dns.resolver.NoAnswer:
            pass
        except dns.resolver.NXDOMAIN:
            pass
        except Exception as e:
            raise
        print(outstr[:-1])

        try:
            ans = resolv.query(nextDomain, 'NSEC')
            for item in ans.response.answer:
                for sub in item:
                    # since it's a cyclical list, stop when we reach the beginning
                    if str(sub.next) != targetDomain:
                        #print(sub.next)
                        nextDomain = sub.next
                    else:
                        return
        except dns.resolver.NoAnswer:
            pass
        except dns.resolver.NXDOMAIN:
            pass
        except Exception as e:
            raise

if __name__ == '__main__':
    main()
