# cloud-dyndns

[![Build
Status](https://travis-ci.org/natlownes/cloud-dyndns.png?branch=master)](https://travis-ci.org/natlownes/cloud-dyndns)

Use a cloud DNS provider like a dynamic dns service.  A Ruby executable to
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

where `$your_yaml_file` is the path to a file that looks like:

# config example

```yaml
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
```

# environment variables

we can also config using environment variables:

* ``

# command line options

there's -c/--config and -l/--log:

* --config is optional if environment variables are set:  a path to your config
  file
* --log is optional:  if not given it will log to stdout.  if given a path it
  will log to that file.

# crontab example

```
*/15 * * * * cloud-dyndns --config /Users/nat/.cloud-dyndns.yml >> ~/.cdyndns.log
```

will make sure your domain is up to date every 15 minutes, and will log to
`~/.cdyndns.log`

If you use rbenv, rvm, or rb-john-wanamaker...I'm not sure what you can do.  I
vaguely remember with rvm you could create "wrappers".  I know it's possible to
use software the way you might want.  Sorry I'm not more helpful here.

# other

I refactored this and added tests for release.  I've been using it for about a
year.  [Fog](http://fog.io/) is good, contributions welcome.

# testing

```
bundle install --without development
```

```
rake test
```

This will allow running tests on ruby >= 1.9.2

# development

```
bundle install --without nothing
```

(See [this SO
post](http://stackoverflow.com/questions/4118055/rails-bundler-doesnt-install-gems-inside-a-group)
about why I suggest just throwing that `--without nothing` in there.

```
bundle exec guard
```

Development requires Ruby >= 1.9.3 due to the listen gem's requirement of Ruby
1.9.3.

# todo

* allow setting of hostmaster email?
* allow usage of a different wtfismyip-type service?
* use a version of fog that requires only 1.8.7?
  * this would include adding a fix for [this
    issue](https://github.com/fog/fog/issues/1093) in this library.

