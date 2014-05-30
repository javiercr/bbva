# BBVA

Ruby gem with command line tool to retrieve BBVA bank accounts balance and transactions.

It uses the same API that the offical BBVA mobile app uses. Requieres the same user and password that is used for accessing http://bbva.es

## Motivation

I wrote this gem to cover my own needs. The [BBVA web app](https://www.bbva.es/) is painful to use and there is no public API. However their [Android mobile app](https://play.google.com/store/apps/developer?id=BBVA) is quite great. I thought the mobile app should be using some kind of API, so after some research I figured out how to use that exact same API from a Ruby client.

## Disclaimer

This gem has been tested only with one BBVA user account (which is a company bank account). It hasn't been tested with personal accounts, however as far as I know it should work fine. Please use this at your own risk.

## Installation

    $ git clone https://github.com/javiercr/bbva.git
    $ cd bbva
    $ bundle
    $ rake install

## Usage

Retrieve balance account

    $ bbva balance --user YOUR_BBVA_USER --password YOUR_BBVA_PASSWORD

Retrieve transactions for the last 24 months and expor them to CSV and YAML (in the working directory)

    $ bbva transactions --user YOUR_BBVA_USER --password YOUR_BBVA_PASSWORD

If you don't want to pass your user and password everytime you can define them in your .bash_profile

    export BBVA_USER=YOUR_BBVA_USER
    export BBVA_PASSWORD=YOUR_BBVA_USER

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
