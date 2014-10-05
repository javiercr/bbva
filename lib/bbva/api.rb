require 'uri'
require 'erb'
require 'ostruct'
require 'colorize'
require 'pp'
require 'faraday'
require 'faraday'
require 'faraday-cookie_jar'
require 'faraday_middleware'

module BBVA
  class API
    API_ENDPOINT = "https://bancamovil.grupobbva.com"

    def initialize(user, password, debug: false)
      @user = format_user(user)
      @password = password
      @debug = debug

      create_connection
      login
      get_account_data # we need to call this before anything else
    end

    def get_balance
      puts 'BBVA::API get_balance'.yellow if @debug
      
      response = @connection.post do |req|
        req.url '/ENPP/enpp_mult_web_frontiphone_01/OperacionCBTFServlet?proceso=TLNMCuentasPr&operacion=TLNMListadoCuentasOp&accion=relacionCtas'
        req.body = "xmlEntrada=%3CMSG-E%3E%3C%2FMSG-E%3E"
        req.headers['Content-type'] = 'application/x-www-form-urlencoded; charset=utf-8'
        req.headers['Connection'] = 'Keep-Alive'
        req.headers['Cookie2'] = '$Version=1'
        req.headers['Accept'] = 'application/xml,text/xml'
      end
      
      pp response.body if @debug
      
      response.body['MSG_S']['LISTADOCTA']['E']['SALDO']
    end

    def get_transactions(options = {})
      start_date    = format_date(options.fetch(:start_date))
      end_date      = format_date(options.fetch(:end_date))
      show_income   = options.fetch(:show_income, true)
      show_payments = options.fetch(:show_payments, true)

      # We need to call get_balance before getting the transactions, 
      # otherwise the API throws an error
      get_balance 

      transactions = []
      i = 0
      loop do
        response = @connection.post do |req|
          req.url '/ENPP/enpp_mult_web_frontiphone_01/OperacionCBTFServlet?proceso=TLNMCuentasPr&operacion=TLNMMovimientosCuentasOp&accion=relacionMvtsEstr'
          params = {
            fecha_inicio: start_date, 
            fecha_fin: end_date, 
            primera_invocacion: (i == 0).to_s,
            filtro_ingresos: show_income.to_s,
            filtro_pagos: show_payments.to_s
          }
          content = render_erb(template_path('transactions'), params)
          req.body = "xmlEntrada=" + URI.escape(content)
          req.headers['Content-type'] = 'application/x-www-form-urlencoded; charset=utf-8'
          req.headers['Connection'] = 'Keep-Alive'
          req.headers['Cookie2'] = '$Version=1'
          req.headers['Accept'] = 'application/xml,text/xml'
        end
        break if response.body['MSG_S']['LISTADOMOVSCTA'].nil?

        results = response.body['MSG_S']['LISTADOMOVSCTA']['E']
                
        transactions = if results.nil?
          transactions
        elsif results.is_a?(Hash)
          [results]
        else
          results
        end
        
        i += 1
      end
      transactions
    end

    def get_account_data
      puts 'BBVA::API get_account_data'.yellow if @debug

      response = @connection.get do |req|
        req.url '/ENPP/enpp_mult_web_frontiphone_01/LogonIphoneServlet?action=indexIPHONE&version=3.5&'
      end
      
      pp response.body if @debug
      
      response.body
    end


    private 

    # As far as we know there are two types of identifiers BBVA uses
    # 1) A number of 7 characters that gets passed to the API as it is
    # 2) A DNI number, this needs to transformed before it get passed to the API
    #    Example: "49021740T" will become "0019-049021740T"
    def format_user(user)
      user.upcase!
      
      if user.match /^[0-9]{8}[A-Z]$/ 
        # it's a DNI
        "0019-0#{user}"
      else
        user
      end 
    end

    def login
      puts 'BBVA::API login'.yellow if @debug
      
      response = @connection.post '/DFAUTH/slod/DFServletXML', {
        origen: 'enpp',
        eai_user: @user,
        eai_password: @password,
        eai_URLDestino: '/ENPP/enpp_mult_web_frontiphone_01/LogonIphoneServlet?action=indexIPHONE&version=3.5&',
        eai_tipoCP: 'up',
        idioma: 'CAS'
      }

      puts response.body if @debug
      
      response
    end

    def create_connection
      @connection = Faraday.new(url: API_ENDPOINT) do |faraday|
        # faraday.response :logger if @debug
        faraday.request :url_encoded
        faraday.use FaradayMiddleware::ParseXml,  :content_type => /\bxml$/
        faraday.use :cookie_jar
        faraday.adapter Faraday.default_adapter
      end
      @connection.headers[:user_agent] = 'GEEKSPHONE;GP-Peak;540x888;Android;4.0.4;BMES;3.5'
    end

    def template_path(name)
      File.expand_path("./../requests/#{name}.xml.erb", __FILE__)
    end

    def render_erb(template_file, locals)
      ERB.new(File.read(template_file)).result(OpenStruct.new(locals).instance_eval { binding })
    end

    # Format date for the API
    def format_date(date)
      date.strftime "%Y%m%d"
    end
  end
end