# Capistrano Wizard

Wizard for bootstrapping Capistrano configs.

## Installation

    $ git clone git@github.com:igas/capistrano-wizard.git
    $ rake install

## Usage

Run `cap-wizard` for interactive mode or pass arguments described below

    Usage: cap-wizard [options]

    Specific options:
            --name NAME                  Set application name
            --repo-url URL               Set repository url
            --deploy-to PATH             Set deployment path
            --skip-ruby-manager          Don't use ruby manager
            --rvm [RUBY_VERSION]         Use rvm with RUBY_VERSION
            --rbenv [RUBY_VERSION]       Use rbenv with RUBY_VERSION
            --chruby [RUBY_VERSION]      Use chruby with RUBY_VERSION
            --[no-]rails                 Add rails plugin
            --[no-]bundler               Add bundler plugin (not necessary if rails plugin used)

    Common options:
        -v, --version                    Show version
        -h, --help                       Show help

Grab your configs from `$cwd/result` after Capistrano Wizard finished work.

## Tests

Use `rake test` to run tests

## Contributing

1. Fork it ( http://github.com/igas/capistrano-wizard/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Ensure all tests passed (`rake test`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
