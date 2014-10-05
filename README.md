# BBVA

Ruby gem with command line tool for retrieving BBVA bank accounts balance and transactions.

It uses the same API that the offical BBVA mobile app uses. Requieres the same user and password that are used for accessing http://bbva.es

## Motivation

I wrote this gem to cover my own needs. The [BBVA web app](https://www.bbva.es/) is painful to use and there is no public API. However their [Android mobile app](https://play.google.com/store/apps/developer?id=BBVA) is quite great. I thought the mobile app should be using some kind of API, so after some research I figured out how to use that exact same API from a Ruby client.


## Installation

    $ git clone https://github.com/javiercr/bbva.git
    $ cd bbva
    $ bundle
    $ rake install

## Usage from terminal

Retrieve balance account

    $ bbva balance --user YOUR_BBVA_USER --password YOUR_BBVA_PASSWORD

Retrieve transactions for the last 24 months (maximum allowed by the API) and export them to CSV and YAML (in the working directory)

    $ bbva transactions --user YOUR_BBVA_USER --password YOUR_BBVA_PASSWORD

Retrieve transactions for the last 5 days (including today) and export them to CSV and YAML (in the working directory)

    $ bbva transactions --user YOUR_BBVA_USER --password YOUR_BBVA_PASSWORD --days 5

If you don't want to pass your user and password everytime you can define them in your .bash_profile

    export BBVA_USER=YOUR_BBVA_USER
    export BBVA_PASSWORD=YOUR_BBVA_USER
    
## Usage from Ruby

You can also use this gem from your own app as library. To do so first you must initialize a BBVA::API object

```ruby
require 'bbva'
@api = BBVA::API.new(YOUR_BBVA_USER, YOUR_BBVA_PASSWORD)
```

Now you can fetch your balance:

```ruby
@api.get_balance
```

Or your transactions (you must pass the range of dates)

```ruby
@api.get_transactions(start_date: (Date.today - 24.months), end_date: Date.today)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
