# cloud-dyndns

Use a cloud DNS provider like a dynamic dns service.  A small Ruby script to
stick in a crontab.  If the excellent [fog](http://fog.io/) supports the
service, cloud-dyndns will (probably) work for you.

# install

```
gem install cloud-dyndns
```

# usage

```
cloud-dyndns --config ~/$your_yaml_file
```

where `$your_yaml_file` is a file that looks like:

# config example

  :credentials:
    :provider: 'AWS'
    :aws_secret_access_key: 'your-secretkeykeykey'
    :aws_access_key_id: 'your-access-id'
  :zones:
    - :domain: "looting.biz"
      :targets:
        - "phl.looting.biz"
        - "*.phl.looting.biz"
    - :domain: "narf.io"
      :targets:
        - "phl.narf.io"
        - "*.phl.narf.io"

# command line options

there's -c/--config and -l/--log:

* --config is mandatory:  a path to your config file
* --log is optional:  if not given it will log to stdout.  if given a path it
  will log to that file.

# crontab example

```
*/15 * * * * cloud-dyndns --config /Users/nat/.cloud-dyndns.yml > ~/.cdyndns.log
```

if you use rbenv or rvm, you'll have to do something like:

TODO

```
*/15 * * * * 
```

make sure your domain is up to date every 15 minutes.

# other

I refactored this and added tests to release publicly.
I've been using it for about a year.  [Fog](http://fog.io/) is good,
contributions welcome.

# todo

* allow setting of hostmaster email?
* allow usage of a different wtfismyip-type service?
