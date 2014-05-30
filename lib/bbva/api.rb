require 'uri'
require 'erb'
require 'ostruct'
require 'faraday'
require 'faraday'
require 'faraday-cookie_jar'
require 'faraday_middleware'

module BBVA
  class API
    API_ENDPOINT = "https://bancamovil.grupobbva.com"

    def initialize(user, password, debug: false)
      @user = user
      @password = password
      @debug = debug
      create_connection
      login
      get_account_data # we need to call this before anything else
    end

    def get_balance
      response = @connection.post do |req|
        req.url '/ENPP/enpp_mult_web_frontiphone_01/OperacionCBTFServlet?proceso=TLNMCuentasPr&operacion=TLNMListadoCuentasOp&accion=relacionCtas'
        req.body = "xmlEntrada=%3CMSG-E%3E%3C%2FMSG-E%3E"
        req.headers['Content-type'] = 'application/x-www-form-urlencoded; charset=utf-8'
        req.headers['Connection'] = 'Keep-Alive'
        req.headers['Cookie2'] = '$Version=1'
        req.headers['Accept'] = 'application/xml,text/xml'
      end
      return response.body['MSG_S']['LISTADOCTA']['E']['SALDO']
    end

    def get_transactions(show_income: true, show_payments: true)
      # we need to call get_balance before getting the transactions, 
      # otherwise the API throws an error
      get_balance 

      # We can only retrieve transactions for the last 24 months
      start_date = (Date.today - 365*2).strftime "%Y%m%d"
      transactions = []
      i = 0
      loop do
        response = @connection.post do |req|
          req.url '/ENPP/enpp_mult_web_frontiphone_01/OperacionCBTFServlet?proceso=TLNMCuentasPr&operacion=TLNMMovimientosCuentasOp&accion=relacionMvtsEstr'
          params = {
            fecha_inicio: start_date, 
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
        transactions = transactions | response.body['MSG_S']['LISTADOMOVSCTA']['E']
        i += 1
      end
      transactions
    end

    def get_account_data
      response = @connection.get do |req|
        req.url '/ENPP/enpp_mult_web_frontiphone_01/LogonIphoneServlet?action=indexIPHONE&version=3.5&'
      end
      return response.body
    end


    private 

    def login
      response = @connection.post '/DFAUTH/slod/DFServletXML', {
        origen: 'enpp',
        eai_user: @user,
        eai_password: @password,
        eai_URLDestino: '/ENPP/enpp_mult_web_frontiphone_01/LogonIphoneServlet?action=indexIPHONE&version=3.5&',
        eai_tipoCP: 'up',
        idioma: 'CAS'
      }
    end

    def create_connection
      # OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
      # conn = Faraday.new(url: 'https://bancamovil.grupobbva.com', proxy: 'http://localhost:8888') do |faraday|

      @connection = Faraday.new(url: API_ENDPOINT) do |faraday|
        faraday.response :logger if @debug
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
  end
end