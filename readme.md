


# Finding Useful VMs

```bash
aws ec2 describe-instance-types --filters \
"Name=processor-info.supported-architecture,Values=x86_64" \
"Name=vcpu-info.default-vcpus,Values=8" \
"Name=memory-info.size-in-mib,Values=32768" \ 
--query "InstanceTypes[*].InstanceType" > useful-ec2
```
 Use this list inside `ec2-finder.py`  with `os=Linux` and `region=us-east-1`