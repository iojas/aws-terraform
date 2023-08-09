import requests
import json

def get_ec2_spot_interruption(instances=[], os=None, region=None):
    results = {}
    url_interruptions = "https://spot-bid-advisor.s3.amazonaws.com/spot-advisor-data.json"
    try:
        response = requests.get(url=url_interruptions)
        spot_advisor = json.loads(response.text)['spot_advisor']
    except requests.exceptions.ConnectionError:
        return
    rates = {
        0: "<5%",
        1: "5-10%",
        2: "10-15%",
        3: "15-20%",
        4: ">20%"
    }
    for ii in instances:
        rate = spot_advisor[region][os][ii]['r']
        results[ii] = rate

    sorted_result = dict(sorted(results.items(), key=lambda x: x[1]))
    final_result = {}
    for k,v in sorted_result.items():
        final_result[k] = rates[v]
    print(final_result)
    print(final_result.keys())


if __name__ == "__main__":
    spot_instance_types = [
        "m5zn.2xlarge",
        "m5dn.2xlarge",
        "m5a.2xlarge",
        "g5.2xlarge",
        "m6a.2xlarge",
        "m6id.2xlarge",
        "t2.2xlarge",
        "d3en.2xlarge",
        "trn1.2xlarge",
        #    "t3.2xlarge",
        "m7i-flex.2xlarge",
        "t3a.2xlarge",
        "m7i.2xlarge",
        "m5ad.2xlarge",
        "g4ad.2xlarge",
        "h1.2xlarge",
        "m6idn.2xlarge",
        "m4.2xlarge",
        "m5d.2xlarge",
        "m6in.2xlarge",
        "m5.2xlarge",
        "m5n.2xlarge",
        "m6i.2xlarge",
        "g4dn.2xlarge"
    ]
    get_ec2_spot_interruption(instances=spot_instance_types, region="us-east-1", os="Linux")