require 'thor'
require 'date'
require 'yaml'
require 'csv'

module BBVA
  class CLI < Thor
    
    desc "bbva balance", "get account's balance"
    option :user, default: ENV['BBVA_USER']
    option :password, default: ENV['BBVA_PASSWORD']
    def balance
      @bbva_user = options[:user]
      @bbva_password = options[:password]
      balance = bbva_api.get_balance
      puts "Balance: #{balance} €"
    end

    desc "bbva transactions", "get account's transactions for last 24 months and export them to CSV and YML"
    option :user, default: ENV['BBVA_USER']
    option :password, default: ENV['BBVA_PASSWORD']
    option :only_payments, :type => :boolean
    def transactions
      @bbva_user = options[:user]
      @bbva_password = options[:password]

      if options[:only_payments]
        transactions = bbva_api.get_transactions(show_income: false, show_payments: true)
      else
        transactions = bbva_api.get_transactions
      end
      puts "Number of transactions fetched: #{transactions.count}"
      
      File.open("#{output_path}/transactions.yml", "wb") do |f|     
        f.write(transactions.to_yaml)   
      end
      puts "Transactions exported to #{output_path}/transactions.yml"

      CSV.open("#{output_path}/transactions.csv", "wb") do |csv|
        csv << ["indice", "fecha", "concepto", "descripcion", "etiqueta", "importe"]

        transactions.each do |trans|
          date = DateTime.strptime(trans['FECHAOP'], "%Y%m%d")
          csv << [trans['INDICE'], date.strftime("%d/%m/%Y"), trans['CONCEPTO'], trans['DESCRIPCION'], trans['ETIQUETA'], trans['IMPORTECTA']]
        end
      end
      puts "Transactions exported to #{output_path}/transactions.csv"

      puts 'Last transaction:'
      puts transactions.first.to_yaml
    end

    private

    def bbva_api
      @bbva_api ||= BBVA::API.new(@bbva_user, @bbva_password)
    end

    def output_path
      Dir.pwd
    end
  end
end