#!/usr/bin/env python3

import requests
import json

class Dns():
    def __init__(self):
        self.account_id = ''
        self.token = ''
        self.base_url = 'https://api.cloudflare.com/client/v4'
        self.headers = {"Content-Type": "application/json", "Authorization": "Bearer "+self.token}


    def get_dns_records(self, zone_id):
        api = '/zones/'+zone_id+'/dns_records'
        resp = requests.get(self.base_url+api, headers=self.headers)
        return resp.json()['result']

    def get_domain_dict(self):
        api = '/zones'
        params = {'per_page':'50'}
        resp = requests.get(self.base_url+api, params=params, headers=self.headers)
        if resp.status_code == 200:
            #print(resp.json())
            content = resp.json()['result']
            return content
        else:
            print(resp.text)

    def get_domain_name_id(self):
        content = self.get_domain_dict()
        domain_dict = {domin['name']:domin['id'] for domin in content }
        #print(domain_dict)
        return domain_dict

    def add_domain(self, domain_name):
        api = '/zones'
        payload = {
            "account": {"id": self.account_id},
            "name": domain_name,
            "type": "full"
        }
        resp = requests.post(self.base_url+api, json=payload, headers=self.headers)
        print(resp.content)

    def add_dns_records(self,zone_id):
        api = '/zones/' + zone_id + '/dns_records'
        payload = {
                "content":"test-1365352756.east-1.elb.amazonaws.com",
                "name": "@",
                "proxied": True,
                "type": "CNAME",
                }
        resp = requests.post(self.base_url+api, json=payload, headers=self.headers)
        print(resp.text)

    def delete_dns_record(self, identifier, zone_id):
        api = '/zones/' + zone_id + '/dns_records/' + identifier
        resp = requests.delete(self.base_url+api, headers=self.headers)
        print(resp.content)

    def get_ssl_recommendation(self, zone_id):
        api = '/zones/' + zone_id + '/ssl/recommendation'
        resp = requests.get(self.base_url+api, headers=self.headers)
        print(resp.text)

    def update_ssl_config(self, zone_id):
        api = '/zones/' + zone_id + '/settings/ssl'
        payload = {"value": "full"}
        resp = requests.patch(self.base_url+api, json=payload, headers=self.headers)
        print(resp.text)



if __name__ == '__main__':
    with open('./aaa.txt', 'r') as fd:
        domain_list = fd.readlines()
    dns = Dns()
    domain_name_id = dns.get_domain_name_id()
    #print(domain_name_id)
    for name in domain_list:
        """
        ##add domain
        dns.add_domain(name)
        """
        domain_id = domain_name_id[name.strip('\n').strip()]
        ##update ssl config
        dns.get_ssl_recommendation(domain_id)
        dns.update_ssl_config(domain_id)

        ##add dns_records
        dns_records = dns.get_dns_records(domain_id)
        print(dns_records)
        if dns_records and name in [ r['name'] for r in dns_records ]:
            pass
        else:
            dns.add_dns_records(domain_id)
        

