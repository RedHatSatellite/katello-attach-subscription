# katello-attach-subscription

automatically assign subscriptions to hypervisors based on certain rules

## Description

`katello-attach-subscription` can be used to attach specific subscriptions to Katello hosts in Satellite 6. It is needed when you have multiple subscriptions that can be given to your hypervisors but want a more granular assignment than done by default by Satellite 6. You could for example give a specific subscription to a set of hosts that match a common hostname pattern or were submitted by a specific `virt-who` instance.

When run, `katello-attach-subscription` will execute the following steps:

* Iterate over all content hosts of type `Hypervisor` of your organization
* Search for a subscription that matches by hostname and (optionally) by the submitter
* If such a subscription is found:
    * ensure that it is attached to the content host
    * and all other subscriptions are removed from it

## Requirements

* [Ruby](https://www.ruby-lang.org/)
* [Apipie Bindings](https://github.com/Apipie/apipie-bindings)


## Options

* `-U`, `--uri=URI` URI to the Satellite
* `-u`, `--user=USER` User to log in to Satellite
* `-p`, `--pass=PASS` Password to log in to Satellite
* `-o`, `--organization-id=ID` ID of the Organization
* `-c`, `--config=FILE` configuration in YAML format
* `-n`, `--noop` do not actually execute anything

## Configuration

`katello-attach-subscription` can be configured using an YAML file (`katello-attach-subscription.yaml` by default).

The configuration file consists of two main sections: `settings` and `subs`.

The `settings` section allows to set the same details as the commandline options. Any options given on the command line will override the respective config file settings.

    :settings:
      :user: admin
      :pass: changeme
      :uri: https://localhost
      :org: 1

The `subs` section is an array of hashes which describe the subscriptions to be attached.
Each subscription hash has an `hostname` entry which will be used as an regular expression to match the hostname of the content host in Katello. It also has a `sub` entry, which is the ID of the subscription to be attached to the host. An optional `registered_by` entry can be given to limit the matching to hosts that were submitted by a specific other host. The `type` entry can be set if the host in question is not a hypervisor, but should get a subscription.

    :subs:
      - hostname: esxi123\.example\.com
        sub: 4543828edcf35158c30abc3554c1e36a
      - hostname: esxi[0-9]\.example\.com
        registered_by: 85e65e06-a117-4e8e-8aa1-72cb1e00b930
        sub: b9548e4c9fa20b85f264fbaa2470b726
      - hostname: machine01\.example.com
        type: System
        sub: b9548e4c9fa20b85f264fbaa2470b726
