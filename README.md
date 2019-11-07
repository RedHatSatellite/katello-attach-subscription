# katello-attach-subscription

automatically assign subscriptions to hypervisors based on certain rules

## Description

`katello-attach-subscription` can be used to attach specific subscriptions to Katello hosts in Satellite 6. It is needed when you have multiple subscriptions that can be given to your hypervisors but want a more granular assignment than done by default by Satellite 6. You could for example give a specific subscription to a set of hosts that match a common hostname pattern or were submitted by a specific `virt-who` instance.

When run, `katello-attach-subscription` will execute the following steps:

* Iterate over all content hosts of type `Hypervisor` of your organization
* Search for a subscription that matches by hostname and (optionally) by the submitter (usually identified by the UUID of the `virt-who` instance)
* If such a subscription is found:
    * ensure that it is attached to the content host
    * and all other subscriptions are removed from it

## Requirements

* [Ruby](https://www.ruby-lang.org/)
* [Apipie Bindings](https://github.com/Apipie/apipie-bindings)

## Options

* `-U`, `--uri=URI` URI to the Satellite, this must be https
* `-u`, `--user=USER` User to log in to Satellite
* `-p`, `--pass=PASS` Password to log in to Satellite
* `-o`, `--organization-id=ID` ID of the Organization
* `-c`, `--config=FILE` configuration in YAML format
* `-n`, `--noop` do not actually execute anything
* `-H`, `--used-hypervisors-only` only search for hypervisors that are in use
* `-s`, `--search=SEARCH` only search for hypervisors that are in use
* `--use-cache` read systems from the cache
* `--cache-file=FILE` set the cache file for reading and writing
* `-d`, `--debug` show debug code during execution

## Configuration

`katello-attach-subscription` can be configured using an YAML file (`katello-attach-subscription.yaml` by default).

The configuration file consists of two main sections: `settings` and `subs`.

The `settings` section allows to set the same details as the commandline options. Any options given on the command line will override the respective config file settings.

    :settings:
      :user: admin
      :pass: changeme
      :uri: https://localhost
      :org: 1
      :cachefile: 'katello-attach-subscription.cache'

The `cachefile` is meant to run this program in a faster way because retrieving all of the systems can require huge time.
The `cachefile` will be written each time, while if `--use-cache` is specified on command line it will be readed and will skip systems extraction.

The `subs` section is an array of hashes which describe the subscriptions to be attached.
Each subscription hash has an `hostname` entry which will be used as an regular expression to match the hostname of the content host in Katello.
It also has a `sub` entry, which is an hash of array.
The hash has product as key, which is a string to identify the type of subscription, and the content is an array of RedHat Pool ID of subscription to be attached to the host.

    :subs:
      -
        hostname: esxi[0-9]\.example\.com
        sub:
          rhel:
            - 4543828edcf35158c30abc3554c1e36a
            - 5543828edcf35158c30abc3554c1e36b
          jboss:
            - 6543828edcf35158c30abc3554c1e36c
            - 7543828edcf35158c30abc3554c1e36d
          satellite:
            - 7543828edcf35158c30abc3554c1e36e
      -
        hostname: esxi123\.example\.com
        sub:
          rhel:
            - 4543828edcf35158c30abc3554c1e36a
      -
        hostname: machine01\.example.com
        type: System
        sub:
          rhel:
            - b9548e4c9fa20b85f264fbaa2470b726


## Permissions

The following permissions are required to run `katello-attach-subscription`:

| Resource | Permissions |
|----------|-------------|
| Fact Value | view_facts|
| Host | view_hosts, edit_hosts|
| Subscription | view_subscriptions, attach_subscriptions, unattach_subscriptions|
| Organization | view_organizations|

## Caveats

Currently Satellite is not able to save fact that contain the socket number. Candlepin 2.0 (bug to be linked) and `Virt-who` 0.16 are needed `https://bugzilla.redhat.com/show_bug.cgi?id=1307024`.
Assumption that only 1 sub is needed is done currently.

### **INSTANCE_MULTIPLIER WORKAROUND [BZ 1664614](https://bugzilla.redhat.com/show_bug.cgi?id=1664614)** ###

Due to this bug, we had to do a manual check of the subscription to attach on the host in order to calculate the correct value of `instance_multiplier`.

**Description of problem:**

Output provided by this 2 Satellite API calls:

```
GET /katello/api/organizations/:organization_id/subscriptions/:id
GET /katello/api/subscriptions/:id
```

return `instance_multiplier` with value always set to **1**.

This is incorrect as subscriptions like *RHEL Premium for Physical or Virtual Nodes* requires to be attached with a quantity that is multiple of **2**.

The correct value is retrieved by calling ```GET /katello/api/organizations/:organization_id/subscriptions``` API passing as parameters:

```ruby
:available_for = "host"
:host_id = <the id of the host we need to attach>
```

Tests that were made using various type of subscriptions and return that:

**A.** These subs has 1 as `instance_multiplier`

  - VDC Subs (VDC RHEL, VDC ESL and VDC Smart Management) that would be attached on an Hypervisor
  - VDC Subs that would be attached on a virtual server that is on Fully Entitled Hypervisor
  - Self-support subscriptions for physical or virtual nodes as *"Red Hat Enterprise Linux Server Entry Level, Self-support"*, *"Red Hat Enterprise Linux Server for HPC Compute Node, Self-support (1-2 sockets) (Up to 1 guest)"* and *"Smart Management for Red Hat Enterprise Linux Server for HPC Compute Node (Up to 1 guest)"*

**B.** These subs has 2 as `instance_multiplier`:

- *"Red Hat Enterprise Linux Server, Standard (Physical or Virtual Nodes)"*
- *"Red Hat Enterprise Linux Server, Premium (Physical or Virtual Nodes)"*
- *"Smart Management"*
- *"Red Hat Enterprise Linux Extended Life Cycle Support (Physical or Virtual Nodes)"*


The workaorund code simply checks if the host is **Physical** and need to attach one of the subscriptions in the B list, as only Physical servers may need instance_multiplier **2**.
**Hypervisor**'s subscriptions has `instance_multiplier` set to **1** and Virtual Guest need only **1** sub (fixed value)
