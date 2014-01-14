# BBVA

Command line tool to retrieve BBVA bank accounts balance and transactions.

It uses the same API that the offical BBVA mobile app uses. Requieres the same user and password that is used for accessing http://bbva.es

## Installation

    $ git clone git@bitbucket.org:diacode/bbva.git
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
