# Demeter

Demeter is a command line tool for managing security groups across multiple AWS environments. Demeter was written with the following goals:
*  __Stateless.__  EC2 tags are used to store all metadata about security groups.  This makes it easy for collaborators to make changes to security groups.
*  __Variables.__  Provides a flexible way to define global and per-environment variables to be used in all templates.
*  __Multiple AWS Accounts.__  Maintain a naming scheme for your security groups that can be applied to any region or AWS account.
*  __Infrastructure as code.__  My maintaining your security groups using a demeter repository makes them easy to edit and collaborate on.

## Installation

```shell
% gem install demeter-cli
```


## Usage

[**Detailed instructions - Demeter Example Project**](https://github.com/coinbase/demeter-example)

## Available Commands

`-environment` or short `-e` is a required parameter. It loads the environment variables and sources `.env.<environment>` file

Show general help or specific command help
```
$ demeter help <command>
```

Get list of all managed and unmanaged security groups
```
$ demeter status -e staging
```

Run a plan against environment and return a diff between local state
```
$ demeter plan -e staging
```

Apply diff changes
```
$ demeter apply -e staging
```

When migrating existing security groups you can generate config by specifying existing security group ids
```
$ demeter generate -e staging -ids sg-111111 sg-22222
```

## Contributing

1. Fork it ( https://github.com/coinbase/demeter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

You can use `rake install` to install and test your local development gem

## Copyright

Copyright © 2015 Coinbase Inc. – Released under MIT License

